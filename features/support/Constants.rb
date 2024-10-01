module CI
    module Constants
        @@CI_CONFIGS = Hash.new()

        def self.CI_CORE
            self.CONFIGS["CI_CORE"]
        end

        def self.CI_DB
            self.CONFIGS["CI_DB"]
        end

        def self.CI_SERVER
            self.CONFIGS["XNCITEST_SERVER_URL"]
        end

        def self.CI_RW_SERVER
            self.CONFIGS["XNCITEST_RW_SERVER_URL"]
        end

        def self.UDID
            ENV['DEVICE_TARGET']
        end

        def self.APP
            ENV['APP']
        end

        def self.CONFIGS
            return @@CI_CONFIGS if @@CI_CONFIGS.length > 0
            configs = Hash.new()
            if ENV['CI_CONFIG'].nil?
                config_file = "../ci.cfg"
            else
                config_file = ENV['CI_CONFIG']
            end
            File.readlines(config_file).each do |line|
                key, value = line.chomp.scan(/(.*)=(.*)/)[0]
                configs[key] = value
            end
            @@CI_CONFIGS = configs
        end
    end
end