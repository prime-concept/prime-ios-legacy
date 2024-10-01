module CI
    module Properties
        @@scenarioPath = ''
        def self.isDevice?
            return false if ENV['DEVICE_TARGET'].nil?
            return false if ENV['DEVICE_TARGET'].include?('-')
            return true if ENV['DEVICE_TARGET'].length >= 40
            false
        end

        def self.isCCoveMode?
            return false if ENV['CODE_COVERAGE_ENABLED'].nil?
            return true if ENV['CODE_COVERAGE_ENABLED'] == "1"
            false
        end

        def self.isSimulator?
            not(self.isDevice?)
        end

        def self.isDebug?
            return false if ENV['DEBUG'].nil?
            return true if ENV['DEBUG'] == "1"
            false
        end

        def self.setScenarioPath(path)
            @@scenarioPath = path
        end

        def self.scenarioPath
            @@scenarioPath
        end
    end
end