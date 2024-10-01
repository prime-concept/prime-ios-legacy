require 'calabash-cucumber/launcher'
require 'calabash-cucumber/core'
include Calabash::Cucumber::Core

FeatureMemory = Struct.new(:feature, :device_created, :device_unique_name).new

module Calabash::Launcher
    @@launcher = nil

    def self.launcher
        @@launcher ||= Calabash::Cucumber::Launcher.new
    end

    def self.launcher=(launcher)
        @@launcher = launcher
    end
end


AfterConfiguration do |config|
    FeatureMemory.feature = nil
    FeatureMemory.device_unique_name = nil
    if CI::Properties.isCCoveMode?
        CodeCoverage.clean_up_code_coverage_archive_folder
        CodeCoverage.generate_lcov_baseline_info_file
    end
end

Before '@reset' do
    if CI::Properties.isDevice?
        CI::DeviceController.installIOSApp
    else
        ENV['RESET_BETWEEN_SCENARIOS'] = '1'
        CI::SimulatorController.finishProcesses
    end
end

Before '@reset_db' do
    CI::ServerController.resetDB
end


Before do |scenario|

    launcher = Calabash::Launcher.launcher
    options = {}
    launcher.relaunch(options)
    ENV['RESET_BETWEEN_SCENARIOS'] = '0' if !launcher.device_target?
    @test_object = TEST_OBJECT.new(feature_path: scenario.location)

    if FeatureMemory.feature != scenario.feature then
        ENV['SCREEN_SHOT_COUNTER'] = "0"
        FeatureMemory.feature = scenario.feature
        system("echo [*] ------------------------------")
        system("echo [i] BEGIN: #{FeatureMemory.feature.to_s}")
    end

    if CI::Properties.isCCoveMode?
        CodeCoverage.clean_up_last_run_files
    end

    CI::Properties.setScenarioPath(scenario.location.to_s)
end



After do |scenario|
    launcher = Calabash::Launcher.launcher

    if scenario.passed?
        system("echo [i] OK #{scenario.name}")
    else
        system("echo [w] Failed #{scenario.name} \\(#{scenario.location.to_s}\\)")
    end

    if CI::Properties.isCCoveMode?
        begin
            CodeCoverage.flush
        rescue Errno::ECONNREFUSED
            CodeCoverage.generate_failed_coverage_file(scenario)
            raise
        end
    end

    unless launcher.calabash_no_stop?
        calabash_exit
        if launcher.attached_to_automator?
            launcher.stop
        end
    end

    if CI::Properties.isCCoveMode?
        if scenario.passed?
            CodeCoverage.generate_lcov_info_file(scenario)
        else
            CodeCoverage.generate_failed_coverage_file(scenario)
        end
    end

end

After '@reset_db_after_scenario' do
    CI::ServerController.resetDB
end


at_exit do
    launcher = Calabash::Launcher.launcher
    unless launcher.calabash_no_stop?
        if launcher.attached_to_automator?
            launcher.stop
        end
    end

    if CI::Properties.isCCoveMode?
        CodeCoverage.combine_lcov_info_files
        CodeCoverage.generate_lcov_reports_from_info_file
        CodeCoverage.open_report
    end
end