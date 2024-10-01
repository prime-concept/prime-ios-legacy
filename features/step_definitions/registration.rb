# validation for registration screen fields
Then /^I validate registration screen:$/ do |table|
  # Example:
  # | countery name | Armenia  |
  # | countery code | +374   |
  # | phone number  | 77661200 |
  sleep(0.5)
  wait_for(WAIT_TIMEOUT) { element_exists("view:'UILabel' text:'Your phone number'")}

  request = table.rows_hash

  countery_name = request['countery name']
  countery_code = request['countery code']
  phone_number = request['phone number']

  screen = ParseQuery.new(query('*'))

  screen.parse_and_verify([{ 'text' => 'Your phone number', 'class' => 'UILabel' }])
  screen.parse_and_verify([{ 'label' => 'Next', 'class' => 'UINavigationButton' }])
  screen.parse_and_verify([{ 'text' => countery_name, 'class' => 'UILabel' }])
  screen.parse_and_verify([{ 'id' => 'row-arrow', 'class' => 'UIImageView' }])


  # Cursor is in the phone number field
  if screen.parse([{ 'text' => countery_code , 'class'=> 'UIFieldEditor' }]) == false

    if phone_number == 'Your phone number'

      screen.parse_and_verify([{ 'text'=> '', 'class'=> 'UIFieldEditor' }])
      screen.parse_and_verify([{ 'label'=> 'Next', 'enabled'=> false, 'class'=> 'UINavigationButton' }])

    else

      screen.parse_and_verify([{ 'text'=> phone_number, 'class'=> 'UIFieldEditor' }])
      screen.parse_and_verify([{ 'label'=> 'Next', 'enabled'=> true, 'class'=> 'UINavigationButton' }])

    end

    # Cursor is in the phone number field
  elsif screen.parse([{ 'text'=> countery_code, 'class'=> 'UIFieldEditor' }])

    screen.parse_and_verify([{ 'text'=> phone_number, 'class'=> 'UITextFieldLabel' }])

  else

    print("Propper Coutnery code field didn't found. Expected:\n")
    query("* text:'#{countery_code}'").select do |a| print(a['class'], "\n") end
    raise("Coutnery code field type validation faield")

  end
end

# Entering Code in Code fieid
Then /^I enter password (\w+)$/ do |code|
  wait_for(WAIT_TIMEOUT) { query("PRPasswordField")}
  wait_for_keyboard
  code.size.times do |i|
    keyboard_enter_text code[i]
    sleep(0.1)
  end
end

# Entering Code in Code fieid
Then /^I enter verification code (\w+)$/ do |code|
  wait_for(WAIT_TIMEOUT) { query("view:'UITextFieldLabel' marked:'Code'")}
  wait_for_keyboard
  code.size.times do |i|
    keyboard_enter_text code[i]
    sleep(0.1)
  end
end

# Enter phone number in registration page
Then /^I enter phone number (\w+)$/ do |num|
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists('Your phone number') }
  touch("view:'UITextFieldLabel' marked:'Your phone number'")
  wait_for_keyboard
  num.size.times do |i|
    keyboard_enter_text num[i]
    sleep(0.1)
  end
end
