class DbLogin
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud db login [options]"
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

        case db["engine"]["name"]
        when "mysql"
            system("mysql -u #{db["databases"][0]["username"]} -p#{db["databases"][0]["password"]} -h database.vaporcloud.io -P #{db["port"]} #{db["databases"][0]["database"]}")
        when "postgresql"
            system("psql postgresql://#{db["databases"][0]["username"]}:#{db["databases"][0]["password"]}@database.vaporcloud.io:#{db["port"]}/#{db["databases"][0]["database"]}")
        end
    end
end
