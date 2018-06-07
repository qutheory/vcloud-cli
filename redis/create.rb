class RedisCreate
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud redis create [options]"
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
        spinner = TTY::Spinner.new("[:spinner] Contacting API ...")

        name = prompt.ask('Name:') do |q|
          q.required(true)
        end

        plans = {}
        plans["(Dev) Free $0/month - (23mb memory / TBD connections)"] = "dev-free"
        plans["(Standard) Small $TBD/month - (256mb memory / TBD connections)"] = "standard-small"

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
            name: name,
            size: plan
        }

        spinner.auto_spin
        output = VCloud::Helper::Api::Post::new::call("/v2/redis", object)
        spinner.stop('Done!')

        data = JSON.parse(output.body)

        id = data['deployment']['id']
        app = options[:app]

        CloudSocket::new::run("#{id}", "#{app}")
    end
end
