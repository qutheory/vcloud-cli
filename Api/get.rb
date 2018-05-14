module VCloud
  module Helper
    module Api
      class Get
        def call(endpoint, protected = true, try_again = false, params = {})
          uri = URI("https://api.vaporcloud.io/#{endpoint}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          if protected
            req = Net::HTTP::Get.new(uri, {'Authorization': "Bearer #{VCloud::Authentication::SecretFile::new::parse_secret['access_token']}"})
          else
            req = Net::HTTP::Get.new(uri.path)
          end

          req.set_form_data( params )
          res = http.request(req)

          unless res.kind_of? Net::HTTPSuccess
            if File.exist?("#{File.expand_path('~')}/.vcloud") && try_again == false
              VCloud::Helper::Api::RefreshToken::new::call

              return VCloud::Helper::Api::Get::new::call(endpoint, protected, true, params)
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

          JSON.parse(res.body)
        end

        def callDeploy(endpoint, try_again = false, params = {})
          uri = URI("https://api-deploy.vaporcloud.io/#{endpoint}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          req = Net::HTTP::Get.new(uri, {'Authorization': "Bearer #{VCloud::Authentication::SecretFile::new::parse_secret['access_token']}"})

          #req.set_form_data( params )
          res = http.request(req)

          unless res.kind_of? Net::HTTPSuccess
            if File.exist?("#{File.expand_path('~')}/.vcloud") && try_again == false
              VCloud::Helper::Api::RefreshToken::new::call
            end
          end

          unless res.kind_of? Net::HTTPSuccess
            puts "The call failed\n".colorize(:red)
          end

          res.body
        end
      end
    end
  end
end
