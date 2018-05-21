class DbCreate
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud db create [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
        end

        opt_parser.parse!

        unless options[:app]
            puts opt_parser
            exit
        end

        prompt = TTY::Prompt.new
        spinner = TTY::Spinner.new("[:spinner] Creating database server ...")

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
        #plans["(Dev) Free $0/month - (20K rows / 20 connections)"] = "dev-free"
        #plans["(Dev) Hobby $TBD/month - (5M rows / 20 connections)"] = "dev-hobby"
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
            repoName: options[:app],
            name: name,
            size: plan,
            engine: engine,
            version: engineVersion
        }

        spinner.auto_spin
        output = VCloud::Helper::Api::Post::new::callDeploy("database", object)
        spinner.stop('Done!')
    end
end
