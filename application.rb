class Application
    def verify
        prompt = TTY::Prompt.new

        repoName = prompt.ask('What application slug do you want? (Leave empty for us to pick one)', default: "")

        Whirly.start spinner: "bouncingBar", color: true, status: "Verifying slug" do
            VCloud::Helper::Api::Post::new::call('v2/application/verify', {repoName: repoName}, true)
        end

        cloudGit = prompt.yes?('Do you want to use Vapor Cloud GIT? (Recommended)')

        object = {
            project: {
                id: "13ED3333-ACA2-4148-9EEC-A621F7C2B306"
            },
            repoName: repoName,
            name: "Foobar",
            hosting: {},
            environment: {
                name: "production"
            }
        }

        createObj = VCloud::Helper::Api::Post::new::call('v2/application', object, true)

        data = JSON.parse(createObj.body)

        deployId = data["hosting"]["deployment"]["id"]

        unless data["hosting"].nil?
            unless data["hosting"]["gitUser"].nil?
                email = data["hosting"]["gitUser"]["email"]
                password = data["hosting"]["gitUser"]["password"]
                n = Netrc.read
                n["gitv2.vapor.cloud"] = email, password
                n.save
            end
        end

        Whirly.start spinner: "bouncingBar", color: true, status: "Creating repository" do
            redis = Redis.new(:host => '127.0.0.1')
            redis.subscribe_with_timeout(120, "deployLogs_#{deployId}") do |on|
                on.message do |channel, message|
                    data = JSON.parse(message)
                    if data["finish"]
                        redis.unsubscribe()
                    end
                end
            end
        end

        return repoName

    end
end
