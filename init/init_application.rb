class InitApplication
    def run
        projectId = InitProject.new.run
        prompt = TTY::Prompt.new
        repoName = prompt.ask('What application slug (https://slug.vaporcloud.io) do you want?', default: "")
        name = prompt.ask('What application name do you want?', default: "")

        regions = {}
        regions["do-fra (Digital Ocean - Frankfurt)"] = "do-fra"
        begin
          prompt = TTY::Prompt.new
          region = prompt.select('Choose region', regions)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        object = {
            project: {
                id: projectId
            },
            repoName: repoName,
            name: name,
            hosting: {},
            environment: {
                name: "production"
            }
        }

        createObj = VCloud::Helper::Api::Post::new::call('v2/application', object, true)

        data = JSON.parse(createObj.body)

        `git remote add cloud git@git.v2.vapor.cloud:#{repoName}`

        `git push cloud master -o init`
        `git commit -am "Init Vapor Cloud" --allow-empty`

        puts "You application is now created, and you can deploy by running"
        puts "git push cloud master:prodution"

        return repoName
    end
end
