module VCloud
  module Authentication
    class Auth
      def login
        VCloud::Authentication::Login::new::login
      end

      def create
        VCloud::Authentication::CreateUser::new::create
      end

      def logout
        `rm ~/.vcloud`

        puts 'You are now logged out'.colorize(:green)
      end
    end
  end
end
