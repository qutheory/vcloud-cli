class ReplicaConfig
    def run
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud replica config [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
          opts.on('-e', '--env ENVIRONMENT', 'Application environment') { |v| options[:env] = v }
        end

        opt_parser.parse!

        unless options[:app]
            puts opt_parser
            exit
        end

        unless options[:env]
            puts opt_parser
            exit
        end

        configurations = {}
        ARGV.each do |key|
          unless key == 'cloud' || key == 'replica' || key == 'config' || key == 'modify'
            val_split = key.split('=')
            unless val_split[0] && val_split[1]
              puts 'Invalid format'.colorize(:red)
              exit
            end

            configurations[val_split[0]] = val_split[1]

            #puts "Adding:\nKey: #{val_split[0]}\nValue: #{val_split[1]}\n\n"
          end
      end

      prompt = TTY::Prompt.new
      spinner = TTY::Spinner.new("[:spinner] Updating config ...")

      puts ""
      puts "WARNING: Modifying config variables will reboot your replicas"
      puts ""
      puts "Do you want to add the following configuration to your replicas"
      configurations.each do |key, value|
          puts "#{key}=#{value}"
      end
      unless prompt.yes?("Are you sure?")
          exit 0
      end

      spinner.auto_spin
      output = VCloud::Helper::Api::Patch::new::call("v2/config?application=#{options[:app]}&environment=#{options[:env]}", configurations, true)
      spinner.stop('Done!')

      data = JSON.parse(output.body)

      id = data['deployment']['id']
      app = options[:app]

      CloudSocket::new::run("#{id}", "#{app}")
    end

    def get
        options = {}
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: vapor-alpha cloud replica config [options]"
          opts.separator  ""
          opts.separator  "Options"
          opts.on('-a', '--app APP', 'Application slug') { |v| options[:app] = v }
          opts.on('-e', '--env ENVIRONMENT', 'Application environment') { |v| options[:env] = v }
        end

        opt_parser.parse!

        unless options[:app]
            puts opt_parser
            exit
        end

        unless options[:env]
            puts opt_parser
            exit
        end

        prompt = TTY::Prompt.new
        spinner = TTY::Spinner.new("[:spinner] Fetching config ...")

        spinner.auto_spin
        output = VCloud::Helper::Api::Get::new::call("v2/config?application=#{options[:app]}&environment=#{options[:env]}", true)
        spinner.stop('Done!')
        #puts output
        #data = JSON.parse(output)
        data = output

        data.each do |key, value|
            puts "#{key['key']}:\t#{key['value']}"
        end
    end
end
