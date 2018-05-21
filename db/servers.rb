class DbServers
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud db create [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
          opts.on('-e', '--env Environment', 'Environment') { |v| options[:env] = v }
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

        db = VCloud::Helper::Api::Get::new::call("v2/database/databases?application=#{options[:app]}&environment=#{options[:env]}", true)

        puts "Credentials (#{db["database"]["environment"]["name"]} environment):"
        puts "Username: ".colorize(:light_blue) + db["database"]["username"]
        puts "Database: ".colorize(:light_blue) + db["database"]["database"]
        puts "Password: ".colorize(:light_blue) + db["database"]["password"]
        puts "Hostname: ".colorize(:light_blue) + "database.v2.vapor.cloud"
        puts "Port: ".colorize(:light_blue) + "#{db["server"]["port"]}"
    end
end
