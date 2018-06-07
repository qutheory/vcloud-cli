class DbCreate
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud db create [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
          opts.on('-e', '--env ENVIRONMENT', 'Environment name') { |v| options[:env] = v }
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
        spinner = TTY::Spinner.new("[:spinner] Creating database ...")

        name = prompt.ask('Name:') do |q|
          q.required(true)
        end

        engines = VCloud::Helper::Api::Get::new::call('v2/database/engines', true)

        enginesObj = {}
        engineVersions = {}

        engines.each do |key|
            enginesObj[key["name"]] = key["name"]
            engineVersions[key["name"]] = {}
            key["versions"]["versions"].each do |version|
                engineVersions[key["name"]][version] = version
            end
        end

        begin
          prompt = TTY::Prompt.new
          engine = prompt.select('Choose engine', enginesObj)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        begin
          prompt = TTY::Prompt.new
          engineVersion = prompt.select('Choose version', engineVersions[engine])
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        plans = {}
        plans["(Dev) Free $0/month - (20K rows / 20 connections)"] = "dev-free"
        plans["(Dev) Hobby $TBD/month - (5M rows / 20 connections)"] = "dev-hobby"
        plans["(Standard) Small $TBD/month - (1GB memory / TBD connections)"] = "standard-small"

        begin
          prompt = TTY::Prompt.new
          plan = prompt.select('Choose plan', plans)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        regions = {}
        regions["do-fra (Digital Ocean - Frankfurt)"] = "do-fra"
        begin
          prompt = TTY::Prompt.new
          region = prompt.select('Choose region', regions)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        object = {
            application: options[:app],
            environment: options[:env],
            name: name,
            size: plan,
            engine: engine,
            version: engineVersion,
            region: region
        }

        spinner.auto_spin
        output = VCloud::Helper::Api::Post::new::call("v2/database", object)
        spinner.stop('Done!')

        data = JSON.parse(output.body)

        id = data['deployment']['id']
        app = options[:app]

        CloudSocket::new::run("#{id}", "#{app}")

        # Update configuration

        configurations = {}
        configurations[data['database']['token']] = data['database']['connectUrl']

        config_spinner = TTY::Spinner.new("[:spinner] Adding #{data['database']['token']} ...")
        config_spinner.auto_spin
        config_output = VCloud::Helper::Api::Patch::new::call("v2/config?application=#{options[:app]}&environment=#{options[:env]}", configurations, true)
        config_spinner.stop('Done!')

        config_data = JSON.parse(config_output.body)

        id = config_data['deployment']['id']
        app = options[:app]

        CloudSocket::new::run("#{id}", "#{app}")
    end
end
