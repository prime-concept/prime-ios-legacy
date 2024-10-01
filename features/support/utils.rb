module CI

    module Application
        extend Calabash::Cucumber::Operations
        def self.flush_code_coverage
            backdoor('flushGCov:', '')
        end
    end


    module ServerController
        def self.resetDB
            command = File.expand_path(CI::Constants.CI_CORE + '/utils/server_update_data.sh')
            option = 'db'
            input = '-input ' + CI::Constants.CI_DB + '/last_data_config.json'
            data = '-server ' + CI::Constants.CI_RW_SERVER
            redirect = '> /dev/null'
            execute = [command, option, input, data, redirect].join(' ')
            Utils.runSystemCommand(execute, 'resetting datebase...')
        end
    end


    module DeviceController
        def self.installIOSApp
            command = File.expand_path('/usr/local/bin/ios-deploy')
            device = '-i ' + CI::Constants.UDID
            app = '-b ' + "\"#{CI::Constants.APP}\""
            options = '-r -t 5'
            redirect = '> /dev/null'
            execute = [command, device, "#{app}", options, redirect].join(' ')
            Utils.runSystemCommand(execute, 'installing app...')
        end
    end


    module SimulatorController
        def self.finishProcesses
            execute = 'bundle exec run-loop simctl manage-processes'
            Utils.runSystemCommand(execute, 'cleanup processes...')
        end
    end

    module Utils
        def self.runSystemCommand(command, title)
            self.logInfo(title)
            self.logInfo(command) if CI::Properties.isDebug?
            system(command)
            logError('Error at executing: ' + command) if not $?.success?
        end

        def self.logInfo(text)
            puts('' + text)
        end

        def self.logError(text)
            puts('[error] ' + text)
        end

    end

end 