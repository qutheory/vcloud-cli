class CloudSocket
    def run(id, application)
        EM.run {
            #ws = Faye::WebSocket::Client.new("ws://localhost:8080/listen/#{id}/#{application}", [],
            ws = Faye::WebSocket::Client.new("wss://deploy-api.v2.vapor.cloud/listen/#{id}/#{application}", [],
                :headers => {'Authorization' => "#{VCloud::Authentication::SecretFile::new::parse_secret['access_token']}"},
            )

            ws.on :message do |event|
                puts event.data
            end

            ws.on :close do |event|
                ws = nil
                EM.stop
            end
        }
    end
end
