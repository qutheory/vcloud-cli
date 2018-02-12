module VCloud
  module Authentication
    class Login
      def login
        prompt = TTY::Prompt.new

        begin
          email = prompt.ask('E-mail:') do |q|
            q.required(true)
            q.validate(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*(\+[a-z0-9-]+)?@[a-z0-9-]+(\.[a-z0-9-]+)*$/i, 'Invalid email address')
          end
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        begin
          password = prompt.ask('Password:', echo: false) do |q|
            q.required(true, 'Please enter a password')
          end
        rescue SystemExit, Interrupt, TTY::Prompt::Reader::InputInterrupt
          exit
        end

        request = {
            'email': email,
            'password': password,
        }

        res = VCloud::Helper::Api::Post::new::call('admin/login', request, false)

        if res.kind_of? Net::HTTPSuccess
          details = JSON.parse(res.body)

          VCloud::Authentication::SecretFile::new::write_entry('access_token', details['accessToken'])
          VCloud::Authentication::SecretFile::new::write_entry('refresh_token', details['refreshToken'])

          me = VCloud::Helper::Api::Get::new::call('admin/users/me', true)

          VCloud::Authentication::SecretFile::new::write_entry('name', me['name']['first'])

          puts 'You are now logged in to Vapor Cloud CLI'.colorize(:green)
          
        else
          puts 'Please check email and password are correct'.colorize(:red)
          login
        end
      end
    end
  end
end
