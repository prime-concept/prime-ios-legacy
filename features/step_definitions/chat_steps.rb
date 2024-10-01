##############################################################################
# chat

# Get last message
Then /^I enter "([^\"]*)" into chat field$/ do |text|
  touch("UITextView index: 0")
  wait_for_keyboard
  keyboard_enter_text text
  sleep(STEP_PAUSE)
  @chat_last_massage = text
end

# Get the time of last message
Then /^I send chat message$/ do
  touch("button marked: 'send message'")
  @chat_last_send_time = DateTime.now.strftime("%R")
  sleep(STEP_PAUSE)
end

# Test last message in chat
Then /^I check last message in chat$/ do
  hash_data = [
    {"class" => "TTTAttributedLabel",   "label" => @chat_last_massage},
    {"class" => "UILabel"},
    {"class" => "UILabel",              "label" => @chat_last_send_time},
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'last_message_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Check current button hidden
Then /^I check "([^\"]+)" button is hidden$/ do |button|
  check_element_does_not_exist("button marked:'#{button}'")
end

# Check current button shown
Then /^I check "([^\"]+)" button is shown$/ do |button|
  check_element_exists("button marked:'#{button}'")
end

# Check microphone button shown
Then /^I check voice recorder button exists$/ do
  wait_for_element_exists("button marked:'microphone'")
end

# Check microphone button shown
Then /^I check voice recorder button does not exist$/ do
  check_element_does_not_exist("button marked:'microphone'")
end

Then /^I long press voice recorder button$/ do
  wait_for_none_animating
  sleep(STEP_PAUSE)
  @voice_record_messages_count = query("view marked:'play_circle'").size
  print("voice_record_messages_count = #{@voice_record_messages_count}")
  touch_hold("button marked:'microphone'")
  wait_for_none_animating
end

Then /^I check a new recording is added$/ do
  wait_for_element_exists("view marked:'play_circle'")
  new_voice_record_messages_count = query("view marked:'play_circle'").size
  print("new_voice_record_messages_count = #{new_voice_record_messages_count}")
  if not (new_voice_record_messages_count > @voice_record_messages_count)
    raise "New voice recording message is not added"
  end
  if (element_does_not_exist("view marked:'0:01'") and element_does_not_exist("view marked:'0:02'"))
    raise "New voice recording text 0:01 or 0:02 is not found"
  end
end

Then /^I clear text in chat field$/ do
  clear_text("UITextView index: 0")
  keyboard_enter_char 'Delete'
end


