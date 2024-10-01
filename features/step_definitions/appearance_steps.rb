##############################################################################
# Appearance, existance

# Check object with specified type
Then /^I wait to see "([^\"]*)" of "([^\"]+)" type$/ do |expected_text, expected_type|
  expected_type = "UI" + expected_type if !expected_type.start_with?('UI')
  wait_for(WAIT_TIMEOUT) {
    res = query("view:'#{expected_type}' marked:'#{expected_text}'")
    res.concat query("view:'#{expected_type}' text:'#{expected_text}'")
    !res.empty?
  }
end

# Check an appearance of objects' group of specified type
Then /^I wait to see group "([^\"]*)" of "([^\"]+)" type$/ do |expected_text_group, expected_type|
  expected_type = "UI" + expected_type if !expected_type.start_with?('UI')
  expected_text_group.split(' ').each do |expected_text|
    puts "Searching #{expected_text} of #{expected_type} type"
    wait_for(WAIT_TIMEOUT) { query("view:'#{expected_type}' marked:'#{expected_text}'")[0] }
  end
end

# Negative check for object appearance of specified type
Then /^I should not see "([^\"]*)" of "([^\"]+)" type$/ do |expected_text, expected_type|
  expected_type = "UI" + expected_type if !expected_type.start_with?('UI')
  res = query("view:'#{expected_type}' marked:'#{expected_text}'")
  res.concat query("view:'#{expected_type}' text:'#{expected_text}'")
  unless res.empty?
    screenshot_and_raise "Expected no element with text nor accessibilityLabel: #{expected_text} of #{expected_type} type, found #{res.join(', ')}"
  end
end

# Check password field exist
Then /^I should see password field$/ do
  wait_for(WAIT_TIMEOUT) {query("view:'PRPasswordField'")}
end

# Check sms verification field exist
Then /^I wait to see verification field$/ do
  wait_for(WAIT_TIMEOUT) { query("view:'UITextFieldLabel' marked:'Code'")}
end

# Check button enabled or disabled
Then /^I check "([^\"]+)" button is (enabled|disabled)$/ do |button, state|
  if state == "enabled"
    check_element_exists("button marked:'#{button}' isEnabled:1")
  else
    check_element_exists("button marked:'#{button}' isEnabled:0")
  end
end

# Check screen title
Then /^I check screen title is "([^\"]+)"$/ do |title|
  wait_for(WAIT_TIMEOUT) {element_exists("navigationBar marked:'#{title}'")}
end

# Check navigation button
Then /^I wait to see "([^\"]+)" navigation button$/ do |title|
  wait_for(WAIT_TIMEOUT) {element_exists("view:'UINavigationBar' descendant label marked:'#{title}'")}
end
