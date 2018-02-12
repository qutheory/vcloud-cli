require "./require"

prompt = TTY::Prompt.new

unless File.exist?("#{File.expand_path('~')}/.vcloud")
    VCloud::Authentication::Login::new::login
end

projects = %w(project1 project2)
project = prompt.enum_select("Select a project", projects)

puts "Selected project: #{project}"

Application.new.verify
