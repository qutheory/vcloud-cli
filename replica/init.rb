class ReplicaInit
    def run(command)
        case command
        when "logs"
            CloudLog.new.run
        when "run"
            Command.new.run
        when "scale"
            ReplicaScale.new.run
        when "restart"
            ReplicaRestart.new.run
        when "config"
            ReplicaConfig.new.run
        when "rollback"
            ReplicaRollback.new.run
        else
            options = {}
            opt_parser = OptionParser.new do |opts|
              opts.banner = "Usage: vapor-alpha cloud db COMMAND"
              opts.separator  ""
              opts.separator  "Commands"
              opts.separator  "    logs\tReturn replica logs"
              opts.separator  "    run \tRun command in replica"
              opts.separator  "    scale \tScale amount of replicas"
              opts.separator  "    restart \tRestart replicas"
              opts.separator  "    config \tAdd config variables"
              opts.separator  "    rollback \tRollback to previous version"
              opts.separator  ""
            end

            opt_parser.parse!

            puts opt_parser
        end
    end
end
