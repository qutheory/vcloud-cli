class CloudAuth
    def run(command)
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud auth COMMAND"
          opts.separator  ""
          opts.separator  "Commands"
          opts.separator  "    login\tLogin to Vapor Cloud"
          opts.separator  "    create\tCreate new user"
          opts.separator  ""
        end

        opt_parser.parse!

        case command
        when "login"
            VCloud::Authentication::Login::new::login
        when "create"
            VCloud::Authentication::CreateUser::new::create
        else
            puts opt_parser
        end
    end
end
