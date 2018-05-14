class InitApplication
    def run
        projectId = InitProject.new.run
        prompt = TTY::Prompt.new
        repoName = prompt.ask('What application slug (https://slug.vaporcloud.io) do you want?', default: "")
        name = prompt.ask('What application name do you want?', default: "")

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

        `git remote add cloud git@git.vaporcloud.io:#{repoName}`

        `git push cloud master -o init`
        #`echo "" >> README.md`
        `git commit -am "Init Vapor Cloud" --allow-empty`

        puts "You application is now created, and you can deploy by running"
        puts "git push cloud master -o production"

        return repoName
    end
end
