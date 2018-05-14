class InitOrganization
    def run
        api = VCloud::Helper::Api::Get::new::call('v2/organizations', true)

        if api['data'].empty?
          return createOrganization
        end

        organizations = {}
        api['data'].each do |key, value|
          organizations[key['name']] = key['id']
        end
        organizations["+ New organization"] = 0

        begin
          prompt = TTY::Prompt.new
          organization = prompt.select('Choose organization', organizations)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        if organization == 0
            organization = createOrganization
        end

        return organization
    end

    def createOrganization
        prompt = TTY::Prompt.new
        organization = prompt.ask('Organization name:') do |q|
          q.required(true)
        end

        object = {
            name: organization
        }

        createObj = VCloud::Helper::Api::Post::new::call('admin/organizations', object, true)

        data = JSON.parse(createObj.body)
        return data["id"]
    end
end
