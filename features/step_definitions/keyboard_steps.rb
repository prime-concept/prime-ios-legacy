##############################################################################
# keys, keyboard

# Simulate backspace
Then /^I press backspace (\d+) times$/ do |mult|
  wait_for_keyboard
  mult.to_i.times do
    keyboard_enter_char "Delete"
  end
end

# Prepare text typing
Then /^I wait for keyboard$/ do
  wait_for_keyboard
end

# Discover keyboard visible or not
Then /^I check keyboard is closed$/ do
  keyboard_visible?
end

# Delete text in textfild
Then /^I clear text in textField (\d+)$/ do |num|
  n = num.to_i - 1
  clear_text("UITextView index:#{n}")
  keyboard_enter_char "Delete"
end

# Type text
Then /^I enter text "([^\"]*)"$/ do |text_to_type|
  wait_for_keyboard
  keyboard_enter_text(text_to_type)
end

Then /^I hide the keyboard$/ do
  2.times do sleep(1) if not keyboard_visible? end
  query "* isFirstResponder:1", :resignFirstResponder if keyboard_visible?
  2.times do sleep(1) if keyboard_visible? end
  raise "Failed to hide the keyboard." if keyboard_visible?
end

Then /^I check keyboard is open$/ do
  5.times do sleep(1) if not keyboard_visible? end
  screenshot_and_raise "Keyboard should be opened" if not keyboard_visible?
end
