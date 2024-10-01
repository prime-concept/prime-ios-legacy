require "#{CI::Constants.CI_CORE}/calabash/image_compare.rb"
################################


# Login commands


# Auto-login with password
Given /^I enter to app$/ do
  @b_IAmPrime = "button marked:'I am PRIME'"
  puts('SCENARIO: ' + CI::Properties.scenarioPath)
  step 'I wait for new version popup and close it'
  sleep(2)
  wait_for(5) {
    view_with_mark_exists('I am PRIME') || view_with_mark_exists('Enter password')
  }
  if not (view_with_mark_exists('Enter password'))
    puts "Starting from Welcome screen"
    step 'I login from beginning'
  else
    puts "Starting from Enter Password screen"
    step 'I should see password field'
    step 'I enter password 0000'
    wait_for(WAIT_TIMEOUT) { view_with_mark_exists('Calendar') }
  end
  sleep(2)
end

Then /^I login from beginning$/ do
  puts 'I pass start screen'
  step 'I pass start screen'
  puts 'I wait see and press "Russia"'
  step 'I wait see and press "Russia"'
  puts 'I select "Armenia" in city list'
  step 'I select "Armenia" in city list'
  puts 'I enter phone number 77661200'
  step 'I enter phone number 77661200'
  puts 'I press next'
  step 'I press next'
  puts 'I wait to see "+37477661200"'
  step 'I wait to see "+37477661200"'
  puts 'I wait to see verification field'
  step 'I wait to see verification field'
  puts 'I enter verification code 7777'
  step 'I enter verification code 7777'
  puts 'I should see password field'
  step 'I should see password field'
  puts 'I enter password 0000'
  step 'I enter password 0000'
  puts 'I should see password field'
  step 'I should see password field'
  puts 'I enter password 0000'
  step 'I enter password 0000'
end

Given /^I am on start screen$/ do
  puts('SCENARIO: ' + CI::Properties.scenarioPath)
  element_exists("view")
  sleep(STEP_PAUSE)
  step 'I wait for new version popup and close it'
end

# Press I am PRIME
Given /^I pass start screen$/ do
  b = "button marked:'I am PRIME'"
  wait_for_element_exists(@b_IAmPrime)
  touch(@b_IAmPrime)
  touch(@b_IAmPrime) if element_exists(@b_IAmPrime)
  wait_for_element_does_not_exist(@b_IAmPrime)
end

# Auto-login with password
Given /^I enter password in start screen$/ do
  step 'I wait for new version popup and close it'
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists('Enter password') }
  touch("PRPasswordField")
  wait_for_keyboard
  keyboard_enter_text "0000"
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists('Calendar') }
end


# Image compare commands

Then /^I compare screen image with golden$/ do
  sleep(0.5)
  screen_compare(@test_object)
end

Then /^I compare image in registration screen$/ do
  screen_compare(@test_object, {:x1=>23, :y1=>37, :x2=>25, :y2=>43})
end

Then /^I compare image in verification code screen$/ do
  screen_compare(@test_object, {:x1=>42, :y1=>28, :x2=>44, :y2=>35})
end

Then /^I compare image in requests screen$/ do
  request_top_badge = {:x1=>57, :y1=>4, :x2=>63, :y2=>7}
  screen_compare(@test_object, request_top_badge)
end

Then /^I compare image in history screen$/ do
  # Draw on the month and year in the history screen
  current_date = {:x1=>29, :y1=>10, :x2=>69, :y2=>15}
  screen_compare(@test_object, current_date)
end

Then /^I compare image in calendar screen$/ do
  sleep(0.5)
  few_day_calendar = {:x1=>0, :y1=>52, :x2=>100, :y2=>58}
  screen_compare(@test_object, few_day_calendar)
end



Then /^I expect fail at "([^\"].*)"$/ do |exec_step|
  skip_check = ((not exec_step.match(".* compare .* golden").nil?) and regolden?)
  expected_fail = false
  begin
    step "#{exec_step}"
  rescue RuntimeError => e
    expected_fail = true
    puts e.message
  rescue LocalJumpError
    expected_fail = true
  end
  raise "Expecting fail at execution of '#{exec_step}'" if (not expected_fail and not skip_check)
end

# do specified operation according to provided device
Then /^I did for iPhone$/ do |table|
  # |iPhone5| I press "Back"     |
  # |else   | I press "Calendar" |

  request = table.rows_hash
  given_options = request.keys
  supported_options = supported_iPhones.values.push('else')

  raise "#{given_options} is not correct. Use #{supported_options}" unless (given_options - supported_options).empty?
  current_iPhone = which_iPhone

  if given_options.include?(current_iPhone) then
    action = request[current_iPhone]
    puts "Choosed option: '#{current_iPhone}'"
    puts "Executing step: '#{current_iPhone}'"
    step "#{action}"
  elsif given_options.include?('else') then
    action = request['else']
    puts "Choosed option: '#{current_iPhone}'"
    puts "Executing step: '#{current_iPhone}'"
    step "#{action}"
  end
end

Then /^I press current date in text field$/ do
  current_date = Date.today.strftime("%Y-%m-%d")
  step("I wait see and press \"#{current_date}\"")
  sleep(STEP_PAUSE)
end

Then /^I expect fail "([^\"].*)" after executing '([^\'].*)'$/ do |req_msg, exec_step|
  expected_fail = false
  begin
    step "#{exec_step}"
  rescue RuntimeError => e
    expected_fail = true
    msg = e.message
  end
  raise "Expecting fail at execution of '#{exec_step}'" if not expected_fail
  raise "Error message #{req_msg} was not found." if /#{req_msg}/.match(msg).nil?
end

Then /^I wait for new version popup and close it$/ do
  b_no = "* marked:'No'"
  e = "* marked:'A new version of the application is available. Install?'"
  5.times do
    (sleep(1) and next) if element_does_not_exist(e)
    next if (element_does_not_exist(b_no))
    touch(b_no)
  end
  wait_for_none_animating
end

Then /^I press password field$/ do
  touch("PRPasswordField")
  sleep(STEP_PAUSE)
end

# profile commands

# Touch arrow for expand profile data
Then /^I expand profile details$/ do
  touch("* marked:'expand_arrow'")
end

# Touch arrow for collaps profile data
Then /^I collapse profile details$/ do
  touch("* marked:'collapse_arrow'")
end



# profile car commands

Then /^I wait for pageLoader$/ do
  30.times do
    q = query("MBProgressHUD")
    (sleep(0.5) and next) if not q.empty?
    sleep(1)
    break
  end
end

Then /^I wait for pdf document$/ do
  30.times do
    q = query("UIPDFPageView")
    (sleep(0.2) and next) if q.empty?
    sleep(1)
    raise "The pdf document was not load" if q.empty?
    break
  end
end


# Generic methods

Then /^I wait to see text "([^\"].*)"$/ do |text|
  wait_for_element_exists("* text:'#{text}'")
end

Then /^I wait see and press "([^\"].*)"$/ do |item|
  wait_for_none_animating
  sleep(STEP_PAUSE)
  query = ''
  ["* marked:'#{item}'","* text:'#{item}'"].each do |q|
    next if element_does_not_exist(q)
    query = q
    break
  end
  screenshot_and_raise("Unable to find element '#{item}'") if query.empty?
  wait_tap(query)
  wait_for_none_animating
end


Then /^I press back$/ do
  wait_for_none_animating
  if (element_exists("view:'UINavigationBar' descendant label marked:'Back'"))
    touch("view:'UINavigationBar' descendant label marked:'Back'")
  elsif (query("view:'UINavigationBar' descendant view:'UIImageView'")).size == 1
    touch("view:'UINavigationBar' descendant view:'UIImageView' index:0")
  else
    touch("view:'UINavigationBar' descendant view:'UIImageView' index:1")
  end
  wait_for_none_animating
end

Then /^I press next$/ do
  wait_tap "view:'UINavigationBar' descendant label marked:'Next'"
end

Then /^I see navigation bar titled "([^\"]*)"$/ do |title|
  q = "view:'UINavigationBar' descendant label marked:'#{title}'"
  wait_for(WAIT_TIMEOUT) { element_exists(q) }
end

Then /^I press "([^\"]*)" on real device$/ do |expected_mark|
  30.times do
    q = query("* marked:'#{expected_mark}'")
    (sleep(0.1) and next) if q.empty?
    touch(q) if !q.empty?
    sleep(1)
    break
  end
end

Then /^I press "([^\"]*)" text field$/ do |name|
  step "I wait see and press \"#{name}\""
end

Then /^I press Save$/ do
  step "I wait see and press \"Save\""
  sleep(3)
end
