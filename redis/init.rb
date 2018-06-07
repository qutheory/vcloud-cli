class RedisInit
    def run(command)
        case command
        when "create"
            RedisCreate.new.run
        else
            options = {}
            opt_parser = OptionParser.new do |opts|
              opts.banner = "Usage: vapor-alpha cloud redis COMMAND"
              opts.separator  ""
              opts.separator  "Commands"
              opts.separator  "    create\tCreate new redis"
              opts.separator  ""
            end

            opt_parser.parse!
            puts opt_parser
        end
    end
end
