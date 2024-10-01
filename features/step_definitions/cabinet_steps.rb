

# Test PAYMENT  CARDS and LOYALTY CARDS buttons
Then /^I check My cards buttons state$/ do |table|
  # Example
  # | PAYMENT CARDS | selected   |
  # | LOYALTY CARDS | unselected |
  request = table.rows_hash
  state = {"selected" => true, "unselected" => false}
  hash_data = [
    {"class" => "UISegmentedControl", "alpha" => 1},
    {"class" => "UISegment",    "label" => "PAYMENT CARDS", "selected" => state[request['PAYMENT CARDS']]},
    {"class" => "UISegmentLabel",   "label" => "PAYMENT CARDS"},
    {"class" => "UIImageView",    "alpha" => 1},
    {"class" => "UISegment",    "label" => "LOYALTY CARDS",   "selected" => state[request['LOYALTY CARDS']]},
    {"class" => "UISegmentLabel",   "label" => "LOYALTY CARDS"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'payment_mismatch_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# pick category in picker screen
Then /^I pick a "([^\"]*)" from list$/ do |expected_mark|
  wait_for_none_animating
  # Get row index of selected label in picker screen.
  @num_select_row = query("pickerView", selectedRowInComponent:0)[0]

  def locator(name)
    "pickerView label marked:'#{name}'"
  end

  # Get label of row by given index.
  def getRowLabel(row)
    query("pickerView",:dataSource, [{pickerView:nil}, {titleForRow:row}, {forComponent:0}])[0]
  end

  # Touch the label in given row.
  def touchRowLabel(i)
    type = getRowLabel(@num_select_row + i)
    touch(locator(type))
  end

  if query(locator(expected_mark)).last.nil?

    # The index of row expected mark in picker screen
    expected_mark_row_index = nil

    # Get picker screen rows count.
    rows_count = query("UIPickerTableView", numberOfRowsInSection:0)[0]

    for i in 0...rows_count
      if getRowLabel(i) == expected_mark
        expected_mark_row_index = i
        break
      end
    end

    screenshot_and_raise("Could not find #{expected_mark} label in picker screen") if expected_mark_row_index.nil?

    (2..100).step(2) do |rows|
      touchRowLabel(-rows) if @num_select_row > expected_mark_row_index
      touchRowLabel(rows) if @num_select_row < expected_mark_row_index
      break if not query(locator(expected_mark)).last.nil?
    end
  end
  touch(locator(expected_mark))
  wait_for_none_animating
end

Then /^I remove phone row with type "([^\"]+)" and number "([^\"]*)"$/ do |phone_type, number|
  sleep(STEP_PAUSE)
  hash_data = [
    {"class" => "UIImageView",  "id" => 'profile_info_remove'},
    {"class" => "UILabel",    "label" => phone_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "SHSPhoneTextField", "text" => number}
  ]
  number = "Phone" if number.empty?
  hash_data.push({"class" => "UITextFieldLabel", "text" => number})
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UIImageView",  "id" => 'profile_info_remove'}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'remove_phone_row_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I remove phone row with type "([^\"]+)" and number "([^\"]*)" in edit mode$/ do |phone_type, number|
  sleep(STEP_PAUSE)
  hash_data = [
    {"class" => "UIImageView",  "id" => 'profile_info_remove'},
    {"class" => "UILabel",    "label" => phone_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "SHSPhoneTextField", "text" => number}
  ]
  h = {}
  if number.empty? then
    h = {"class" => "UITextFieldLabel", "text" => "Phone"}
  else
    h = {"class" => "UIFieldEditor", "text" => number}
  end
  hash_data.push(h)
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UIImageView",  "id" => 'profile_info_remove'}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'remove_phone_row_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I remove email row with type "([^\"]+)" and email "([^\"]*)"$/ do |email_type, email|
  sleep(STEP_PAUSE)
  email = "Email" if email.empty?
  hash_data = [
    {"class" => "UIImageView",  "id" => 'profile_info_remove'},
    {"class" => "UILabel",    "label" => email_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "UITextField", "text" => email}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UIImageView",  "id" => 'profile_info_remove'}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'remove_email_row_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I press on phone type "([^\"]+)" with number "([^\"]*)"$/ do |phone_type, number|
  sleep(STEP_PAUSE)
  hash_data = [
    {"class" => "UILabel",    "label" => phone_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "SHSPhoneTextField", "text" => number}
  ]
  number = "Phone" if number.empty?
  hash_data.push({"class" => "UITextFieldLabel", "text" => number})

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UILabel",  "label" => phone_type}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'phone_type_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I press on email type "([^\"]+)" with email "([^\"]*)"$/ do |email_type, email|
  sleep(STEP_PAUSE)
  email = "Email" if email.empty?
  hash_data = [
    {"class" => "UILabel",    "label" => email_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "UITextField", "alpha" => 1},
    {"class" => "UITextFieldLabel", "text" => email}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UILabel",  "label" => email_type}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'email_type_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I fill "([^\"]+)" in "([^\"]+)" field of edit profile screen$/ do |text, field|
  sleep(STEP_PAUSE)
  touch("UITextFieldLabel marked:'#{field}'")
  keyboard_enter_text(text)
end

Then /^I clean field "([^\"]*)" in edit profile screen$/ do |field_text|
  hash_data = [
    {"class" => "UIFieldEditor",  "text" => field_text},
    {"class" => "_UIFieldEditorContentView", "alpha" => 1},
    {"class" => "UITextSelectionView", "alpha" => 1},
    {"class" => "UIButton", "alpha" => 1}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.set_ignore_classes("UIView")

  object_to_find = {"class" => "UIButton", "alpha" => 1}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'field_edit_profile_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
  sleep(STEP_PAUSE)
end

Then /^I check Transaction history buttons state$/ do |table|
  # Example
  # | History  | selected   |
  # | Expenses | unselected |
  request = table.rows_hash
  state = {"selected" => true, "unselected" => false}

  hash_data = [
    {"class" => "UISegment", "label" => "History", "selected" => state[request['History']]},
    {"class" => "UISegmentLabel", "label" => "History"},
    {"class" => "UIImageView", "alpha" => 1},
    {"class" => "UISegment", "label" => "Expenses", "selected" => state[request['Expenses']]},
    {"class" => "UISegmentLabel", "label" => "Expenses"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'history_screen_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# delete contact row
Then /^I remove contact row with type "([^\"]+)" and contact "([^\"]*)"$/ do |contact_type, contact|
  request = table.rows_hash
  hash_data = [
    {"class" => "UIImageView", "id" => "profile_info_remove"},
    {"class" => "UILabel", "label" => contact_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "UITextField", "text" => contact}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UIImageView", "id" => "profile_info_remove"}

  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'remove_contact_row_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# press contact type
Then /^I press on contact type "([^\"]+)" with contact "([^\"]*)"$/ do |contact_type, contact|

  request = table.rows_hash
  hash_data = [
    {"class" => "UIImageView", "id" => "profile_info_remove"},
    {"class" => "UILabel", "label" => contact_type},
    {"class" => "UIImageView", "id" => "arrow"},
    {"class" => "UITextField", "text" => contact}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UILabel",    "text" => request['category']}

  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'contact_type_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I check navigation bar button "([^\"]*)" is active$/ do |expected_mark|
  sleep(STEP_PAUSE)
  screenshot_and_raise "Button #{expected_mark} is not active" if query("UINavigationButton marked:'#{expected_mark}'",:isEnabled)[0] == 0
end

# press add phone or add email in add contact
Then /^I press (add phone|add email) in edit profile$/ do |name|
  touch(query("UILabel text:'#{name}'").last)
  sleep(STEP_PAUSE)
end

Then /^I check last date$/ do
  last_date = Date.today.prev_month.strftime("%B %Y")
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(last_date) }
end

Then /^I check current date$/ do
  sleep(STEP_PAUSE)
  current_date = Date.today.strftime("%B %Y")
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(current_date) }
end

Then /^I check "([^\"]*)" is selected in settings screen$/ do |expected_mark|
  hash_data = [
    {"class" => "UIImageView", "id" => "filter_cell_check_mark_image_view"},
    {"class" => "UILabel", "label" => expected_mark}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'settings_screen_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Press loyalty card by card number
Then /^I press loyalty card "([^\"]*)" of "([^\"]*)" type$/ do |number, type|
  wait_for_none_animating
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(number) }
  check_view_with_mark_exists(type)
end

Then /^I press note field in bonus card$/ do
  hash_data = [
    {"class" => "UILabel", "label" => "Note"},
    {"class" => "UITextView", "label" => ""}
  ]

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UITextView", "label" => ""}
  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'last_request_field_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I check segment "([^\"]*)" is selected$/ do |expected_mark|
  q = query("UISegment marked:'#{expected_mark}'", :isSelected)[0]
  screenshot_and_raise("#{expected_mark} segment is not selected") if q == 0
end

Then /^I check segment "([^\"]*)" is not selected$/ do |expected_mark|
  q = query("UISegment marked:'#{expected_mark}'", :isSelected)[0]
  screenshot_and_raise("#{expected_mark} segment is not selected") if q == 1
end

Then /^I press comments field in document$/ do
  hash_data = [
    {"class" => "UILabel", "label" => "Comments"},
    {"class" => "UITextField", "text" => ""}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);

  object_to_find = {"class" => "UITextField", "text" => ""}

  object_to_press = qr.get_object(object_to_find)

  unless object_to_press.nil?
    touch(object_to_press)
  else
    qr.print_query_to_file(generate_random_string(header:'comments_field_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I check my car fields$/ do |table|
  text_field_id = 'edit_info_cell_text_field'
  # Example:
  # | brand             |  Mercedes |
  # | model             |  E320     |
  # |registration_plate |  111111   |
  # |color              |  Black    |
  # |vin                |  222222   |
  # |year               |  2017     |
  request = table.rows_hash
  wait_for(WAIT_TIMEOUT) { 
    element_exists("textField id:'#{text_field_id}' text:'#{request['brand']}'") 
  }
  check_element_exists("textField id:'#{text_field_id}' text:'#{request['model']}'")
  check_element_exists("textField id:'#{text_field_id}' text:'#{request['registration_plate']}'")
  check_element_exists("textField id:'#{text_field_id}' text:'#{request['color']}'")
  check_element_exists("textField id:'#{text_field_id}' text:'#{request['vin']}'")
  check_element_exists("textField id:'#{text_field_id}' text:'#{request['year']}'")
end


Then /^I check bonus card type is "([^\"]*)"$/ do |name|
  wait_for_element_exists("UIPickerTextField")
  screenshot_and_raise("#{name} bonus card type was not found") if query("UIPickerTextField").select {|a| a["value"] == "#{name}"}.size == 0
end


Then /^I click on bonus card type "([^\"]*)"$/ do |name|
  wait_for_none_animating
  touch(query("UIPickerTextField").select {|a| a['value'] == "#{name}"}[0])
end


Then /^I click card info icon$/ do
  wait_tap("LoyaltyCardView UIView UIButton UIImageView id:'card_info'")
end

Then /^I click card number field$/ do
  wait_tap("* marked:'add_card_card_number_text_field'")
end

Then /^I check card number is "([^\"]*)"$/ do |number|
  check_element_exists("* marked:'add_card_card_number_text_field' text:'#{number}'")
end

Then /^I click card date field$/ do
  wait_tap("* marked:'add_card_date_text_field'")
end

Then /^I check card date is "([^\"]*)"$/ do |number|
  check_element_exists("* marked:'add_card_date_text_field' text:'#{number}'")
end

Then /^I click card number with text "([^\"]*)"$/ do |number|
  check_element_exists("textField text:'#{number}'")
end

Then /^I press Delete car$/ do
  wait_tap("UITableViewLabel marked:'Delete car'")
end
