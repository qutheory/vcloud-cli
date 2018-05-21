class DbInit
    def run(command)
        case command
        when "create"
            DbCreate.new.run
        when "credentials"
            DbServers.new.run
        when "login"
            DbLogin.new.run
        else
            options = {}
            opt_parser = OptionParser.new do |opts|
              opts.banner = "Usage: vapor-alpha cloud db COMMAND"
              opts.separator  ""
              opts.separator  "Commands"
              opts.separator  "    create\tCreate new database"
              opts.separator  "    credentials\tReturn database credentials"
              opts.separator  "    login\tLogin through CLI to a database server"
              opts.separator  ""
            end

            opt_parser.parse!
            puts opt_parser
        end
    end
end
