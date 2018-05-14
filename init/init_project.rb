class InitProject
    def run
        api = VCloud::Helper::Api::Get::new::call('v2/projects', true)

        if api['data'].empty?
          return createProject
        end

        projects = {}
        api['data'].each do |key, value|
          projects[key['name']] = key['id']
        end
        projects["+ New project"] = 0

        begin
          prompt = TTY::Prompt.new
          project = prompt.select('Choose project', projects)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        if project == 0
            project = createProject
        end

        return project
    end

    def createProject
        organization = InitOrganization.new.run

        prompt = TTY::Prompt.new
        project = prompt.ask('Project name:') do |q|
          q.required(true)
        end

        object = {
            name: project,
            organization: {
                id: organization
            }
        }

        createObj = VCloud::Helper::Api::Post::new::call('v2/projects', object, true)

        data = JSON.parse(createObj.body)
        return data["id"]
    end
end
