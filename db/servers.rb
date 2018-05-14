class DbServers
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

        servers = VCloud::Helper::Api::Get::new::call("v2/database?application=#{options[:app]}", true)

        serversObj = {}

        servers.each do |key|
            serversObj[key["name"]] = key["id"]
        end

        begin
          prompt = TTY::Prompt.new
          server = prompt.select('Choose server', serversObj)
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        db = VCloud::Helper::Api::Get::new::call("v2/database/#{server}", true)

        puts "Credentials (Production environment):"
        puts "Username: ".colorize(:light_blue) + db["databases"][0]["username"]
        puts "Database: ".colorize(:light_blue) + db["databases"][0]["database"]
        puts "Password: ".colorize(:light_blue) + db["databases"][0]["password"]
        puts "Hostname: ".colorize(:light_blue) + "databases.vaporcloud.io"
        puts "Port: ".colorize(:light_blue) + "#{db["port"]}"
    end
end
