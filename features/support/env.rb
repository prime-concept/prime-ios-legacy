require "calabash-cucumber/cucumber"

# This should be set to the parent directory containing the build folders
CODE_COVERAGE_BUILD_PARENT_PATH = ENV['CODE_COVERAGE_BUILD_PARENT_PATH']
if CODE_COVERAGE_BUILD_PARENT_PATH
  intermediates_dir=`cat build.log | grep -m 1 'PROJECT_TEMP_ROOT' | sed -n -e 's/^.*PROJECT_TEMP_ROOT=//p'`
  CODE_COVERAGE_INTERMEDIATES_DIR=intermediates_dir.strip
end

