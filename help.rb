class Help
    def help(argv)
        puts "#{argv}"
        if argv[0]
            cloud
        else
            root
        end

        exit 0
    end

    def root
        help = "Test 1"
        help+= "Test 2"
        puts help
    end

    def cloud
        help = "Test 3"
        help+= "Test 4"
        puts help
    end
end
