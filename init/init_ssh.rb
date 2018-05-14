class InitSsh
    def run
        prompt = TTY::Prompt.new

        api = VCloud::Helper::Api::Get::new::call('v2/git/personal', true)

        unless api["data"] == nil
            return
        end

        if File.exist?(ENV['HOME'] + "/.ssh/id_rsa.pub")
             unless prompt.yes?("We found an SSH key at ~/.ssh/id_rsa, do you want to use this key for Vapor Cloud?")
                 exit 1
             end
         else
             unless prompt.yes?("We didn't find an SSH Key, do you want us to create one for you?")
                 exit 1
             end

             `ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa`
        end

        sshkey = `cat #{ENV['HOME']}/.ssh/id_rsa.pub`

        object = {
            publicKey: sshkey
        }

        createObj = VCloud::Helper::Api::Post::new::call('/v2/git/create/user/ssh', object, true)
    end
end
