require File.dirname(__FILE__) + "/require"

prompt = TTY::Prompt.new

unless File.exist?("#{File.expand_path('~')}/.vcloud")
    VCloud::Authentication::Login::new::login
end

options = {}

if ARGV[0] != "cloud"
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: vapor-alpha COMMAND"
      opts.separator  ""
      opts.separator  "Commands"
      opts.separator  "    cloud\t Vapor Cloud commands"
      opts.separator  ""
    end
    opt_parser.parse!
    puts opt_parser
    exit
end

case ARGV[1]
when "init"
    InitSsh.new.run
    repoName = InitApplication.new.run
when "auth"
    CloudAuth.new.run(ARGV[2])
when "db"
    DbInit.new.run(ARGV[2])
when "replica"
    ReplicaInit.new.run(ARGV[2])
else
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: vapor-alpha cloud COMMAND"
      opts.separator  ""
      opts.separator  "Commands"
      opts.separator  "    auth\t login/create user"
      opts.separator  "    init\t Setup new project"
      opts.separator  "    db  \t Manage Vapor Cloud databases"
      opts.separator  "    replica \t Replica management"
      opts.separator  ""
    end
    opt_parser.parse!
    puts opt_parser
    exit 0
end
