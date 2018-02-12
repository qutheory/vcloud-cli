module VCloud
  module Authentication
    class SecretFile

      def parse_secret
        if File.exist?("#{File.expand_path('~')}/.vcloud")
          YAML.load_file("#{File.expand_path('~')}/.vcloud")
        else
          puts 'Cant find your token, please login'.colorize(:red)
          exit
        end
      end

      def overwrite_entry(key, value)
        currentSecret = parse_secret

        `rm ~/.vcloud`

        currentSecret.each do |yml_key, yml_value|
          if yml_key == key
            write_entry(key, value)
          else
            write_entry(yml_key, yml_value)
          end
        end
      end

      def write_entry(key, value)
        unless File.exist?("#{File.expand_path('~')}/.vcloud")
          `touch ~/.vcloud`
        end

        `echo "#{key}: #{value}" >> ~/.vcloud`
      end
    end
  end
end