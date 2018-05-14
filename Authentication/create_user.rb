module VCloud
  module Authentication
    class CreateUser
      def create
        prompt = TTY::Prompt.new

        begin
          email = prompt.ask('E-mail:') do |q|
            q.required(true)
            q.validate(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*(\+[a-z0-9-]+)?@[a-z0-9-]+(\.[a-z0-9-]+)*$/i, 'Invalid email address')
          end
        rescue SystemExit, Interrupt
          exit
        end

        begin
          password = prompt.ask('Password:', echo: false) do |q|
            q.required(true, 'Please enter a password')
          end
        rescue SystemExit, Interrupt
          exit
        end

        begin
          first_name = prompt.ask('First name:') do |q|
            q.required(true, 'Please enter first name')
          end
        rescue SystemExit, Interrupt
          exit
        end

        begin
          last_name = prompt.ask('Last name:') do |q|
            q.required(true, 'Please enter last name')
          end
        rescue SystemExit, Interrupt
          exit
        end

        request = {
            'email': email,
            'password': password,
            'name': {'first': first_name, 'last': last_name, 'full': "#{first_name} #{last_name}"}
        }

        res = VCloud::Helper::Api::Post::new::call('admin/users', request, false)

        if res.kind_of? Net::HTTPSuccess
          puts 'You are now signed up for Vapor Cloud'.colorize(:green)
        else
          puts 'We could not create the user'.colorize(:red)
        end
      end
    end
  end
end
