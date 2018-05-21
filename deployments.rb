class Deployments
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud run [options]"
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

        api = VCloud::Helper::Api::Get::new::call("v2/deploy/#{options[:app]}/#{options[:env]}", true)

        if api['data'].empty?
          puts "Something went wrong"
          exit 1
        end

        #puts api["data"]
        rows = []

        api['data'].each do |value|
            row = []
            row << value['status']
            row << value['type']

            case value['type']
            when 'code'
                row << "Git hash: #{value['meta']['shortGitHash']}"
            else
                row << ""
            end

            time = Time.parse(value['createdAt'])
            row << time

            if value['user'].nil?
                row << 'N/A'
            else
                row << value['user']['name']['full']
            end

            rows << row
        end

        table = Terminal::Table.new
        table.title = "Deployments #{options[:app]} (#{options[:env]})"
        table.headings = ['Status', 'Type', 'Meta', 'Date', 'User']
        table.rows = rows
        table.style = {:width => 120}

        puts table
    end
end
