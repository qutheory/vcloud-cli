class ReplicaRollback
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud rollback [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
          opts.on('-e', '--env ENVIRONMENT', 'Application environment') { |v| options[:env] = v }
        end

        opt_parser.parse!

        unless options[:app]
            puts opt_parser
            exit
        end

        unless options[:env]
            puts opt_parser
            exit
        end

        prompt = TTY::Prompt.new
        spinner = TTY::Spinner.new("[:spinner] Rolling back replicas ...")

        api = VCloud::Helper::Api::Get::new::call("v2/deploy/#{options[:app]}/#{options[:env]}?type=code", true)

        if api['data'].empty?
          puts "No deployments found"
          exit 1
        end

        deployments = {}
        api['data'].each do |key, value|
          time = Time.parse(key['createdAt'])
          deployments["#{key['meta']['shortGitHash']} (Deployed: #{time})"] = key['meta']['shortGitHash']
        end

        begin
          prompt = TTY::Prompt.new
          deployment = prompt.select('Choose deployment', deployments)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        object = {
            application: options[:app],
            environment: options[:env],
            replicas: replicas
        }

        spinner.auto_spin
        output = VCloud::Helper::Api::Post::new::call("v2/replica/scale", object, true)
        spinner.stop('Done!')
    end
end
