module VCloud
  module Helper
    module Api
      class RefreshToken
        def call
          if ARGV[0] == '--debug'
            puts 'Refreshing token'.colorize(:yellow)
          end
          uri = URI("https://api.vaporcloud.io/admin/refresh")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          
          req = Net::HTTP::Get.new(uri.path, {'Authorization': "Bearer #{VCloud::Authentication::SecretFile::new::parse_secret['refresh_token']}"})

          res = http.request(req)

          if res.kind_of? Net::HTTPSuccess
            body = JSON.parse(res.body)

            VCloud::Authentication::SecretFile::new::overwrite_entry('access_token', body['accessToken'])
          end
        end
      end
    end
  end
end
