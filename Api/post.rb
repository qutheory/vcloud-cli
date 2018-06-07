module VCloud
  module Helper
    module Api
      class Post
        def call(endpoint, data, protected = true, try_again = false)
          uri = URI("https://api.v2.vapor.cloud/#{endpoint}")
          #uri = URI("http://0.0.0.0:8081/#{endpoint}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          if protected
            req = Net::HTTP::Post.new(uri.path, {
                'Content-Type' => 'application/json',
                'Authorization' => "Bearer #{VCloud::Authentication::SecretFile::new::parse_secret['access_token']}"
            })
          else
            req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
          end

          req.body = data.to_json

          res = http.request(req)

          unless res.kind_of? Net::HTTPSuccess
            if File.exist?("#{File.expand_path('~')}/.vcloud") && try_again == false
              VCloud::Helper::Api::RefreshToken::new::call

              return VCloud::Helper::Api::Post::new::call(endpoint, data, protected, true)
            end
          end

          unless res.kind_of? Net::HTTPSuccess
            body = JSON.parse(res.body)
            puts "The call failed\n".colorize(:red)
            puts "Reason: #{body['reason']}"
            exit
          end

          if ARGV[0] == '--debug'
            puts res.body
          end

          res
        end

        def callDeploy(endpoint, data, try_again = false)
          uri = URI("https://api-deploy.v2.vapor.cloud/#{endpoint}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.read_timeout = 500

          req = Net::HTTP::Post.new(uri.path, {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{VCloud::Authentication::SecretFile::new::parse_secret['access_token']}"
          })

          req.body = data.to_json

          res = http.request(req)

          unless res.kind_of? Net::HTTPSuccess
            if File.exist?("#{File.expand_path('~')}/.vcloud") && try_again == false
              VCloud::Helper::Api::RefreshToken::new::call
              return VCloud::Helper::Api::Post::new::callDeploy(endpoint, data, true)
            end
          end

          unless res.kind_of? Net::HTTPSuccess
            body = JSON.parse(res.body)
            puts "The call failed\n".colorize(:red)
          end

          res.body
        end
      end
    end
  end
end
