
##############################################################################
# steps for Calendar

# Get current month and year as shown in Calendar screen
Then /^I check current date is active$/ do
  sleep(STEP_PAUSE)
  current_date = Date.today.strftime("%B")
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(current_date) }
end

# Choose a day on calendar
Then /^I (press|select) (\d+) on calendar$/ do |method, number|
  sleep(STEP_PAUSE)
  touch("label marked:'#{number}'")
end

# Find circles over days
Then /^I validate the day with circle$/ do
  current_month_year = Date.today.strftime("%B %Y")

  if query("* marked:'#{current_month_year}'").empty?
    step "I check day #{1} has circle"
  else
    current_day = Date.today.strftime("%d").to_i
    step "I check day #{current_day} has circle"
  end

end

# Find circles over days
Then /^I check day (\d+) has circle$/ do |expected_day|
  wait_for_none_animating
  sleep(2)
  hash_data = [
    {"class" => "JTCalendarDayView","alpha" => 1},
    {"class" => "UILabel","label" => expected_day},
    {"class" => "JTCircleView","alpha" => 1},
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.set_ignore_classes("PRDotsContainerView")
  qr.parse_data
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'without_circle_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# # Find out the specified day is the current day or has event
# Then /^I check day (\d+) has no circles$/ do |expected_day, symbol|
#   day = expected_day.to_i

#   hash_data = [
#     {"class" => "JTCalendarDayView",  "alpha" => 1},
#     {"class" => "UILabel",            "label" => day},
#     {"class" => "JTCircleView",       "alpha" => 1}
#   ]

#   qr = ParseQuery.new(query('*'));
#   qr.set_array(hash_data);
#   qr.parse_data

#   if qr.is_pattern_found then
#     qr.print_query_to_file(generate_random_string(header:'specified_day_', ext:'.json'))
#     screenshot_and_raise(qr.print_full_status)
#   end
# end

# Get selected current day which is in circle
Then /^I check current day has circle$/ do
  wait_for_none_animating
  current_day = Date.today.strftime("%d").to_i
  step "I check day #{current_day} has circle"
end

Then /^I check first day has circle$/ do
  wait_for_none_animating
  step "I check day 1 has circle"
end


# Check current day has cycle
Then /^I check current day is selected$/ do
  step %(I check current day has circle)
end

Then /^I touch chat button in "([^\"]+)" screen$/ do |screen|
  sleep(STEP_PAUSE)
  touch("* id:'wechat'")
end

Then /^I touch "Type message" to open keyboard$/ do
  sleep(STEP_PAUSE)
  touch("UITextView text:'Type message...'")
end

Then /^I compare image in "([^\"]+)" chat screen$/ do |screen|
  skip_area_chat_content = {:x1=>0, :y1=>9, :x2=>100, :y2=>86}
  screen_compare(@test_object, skip_area_chat_content)
end

Then /^I compare image in "([^\"]+)" chat screen with keyboard$/ do |screen|
  skip_area_chat_content = {:x1=>0, :y1=>9, :x2=>100, :y2=>57}
  screen_compare(@test_object, skip_area_chat_content)
end

Then /^I touch calendar arrow (left|right)$/ do |dir|
  d = 'calendar arrow ' + dir
  sleep(STEP_PAUSE)
  touch("UIButton marked:'#{d}'")
end

Then /^I clear text in textField of "([^\"]+)" chat screen$/ do |screen|
  clear_text("UITextView")
  keyboard_enter_char "Delete"
end

# Find string in scroll list
# Then /^I scroll (down|up) to see "([^\"]+)"$/ do |dir, expected_mark|
#   case dir
#   when "down"
#     until element_exists("* marked:'#{expected_mark}'")
#       scroll("tableView", :down)
#     end
#     scroll("tableView", :down)
#   when "up"
#     until element_exists("* marked:'#{expected_mark}'")
#       scroll("tableView", :up)
#     end
#     scroll("tableView", :up)
#   end
# end

Then /^I press current month$/ do
  wait_for_none_animating
  current_month = Date.today.strftime("%B")
  touch("label marked:'#{current_month}'")
end



# New Calendar Steps


Then /^I check calendar is open and today has circle$/ do
  wait_for_none_animating
  currentDay = getCalendarDay(0)
  dayCurrent = Date.today.strftime("%B %Y")
  hash_data = [
    {"class" => "JTCalendarDayView", "enabled" => "true"},
    {"class" => "UILabel", "value" => currentDay},
    {"class" => "JTCircleView", "enabled" => "true"},
    {"class" => "JTCircleView", "enabled" => "true"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'calendar', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
  screen_compare(@test_object)
end


def checkMonthNameExists(month)
  wait_for_none_animating
  hash_data = [
    {"class" => "UILabel", "value" => month}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'calendar', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
  qr.is_pattern_found
end


Then /^I check current month is opened$/ do
  currentMonth = Date.today.strftime("%B");
  checkMonthNameExists(currentMonth)
end

Then /^I check next month is opened$/ do
  nextMonth = Date.today.next_month.strftime("%B")
  checkMonthNameExists(nextMonth)
end

Then /^I check previous month is opened$/ do
  prevMonth = Date.today.prev_month.strftime("%B")
  checkMonthNameExists(prevMonth)
end

Then /^I swipe calendar left$/ do
  swipe :left, force: :strong, query:"JTCalendarContentView"
end

Then /^I swipe calendar right$/ do
  swipe :right, force: :strong, query:"JTCalendarContentView"
end

Then /^I press Today button on calendar$/ do
  touch:"button marked:'calendar today'"
end

Then /^I close the calendar$/ do
  touch:"* marked:'calendar_arrow_image_view'"
  wait_for_none_animating
end

Then /^I open the calendar$/ do
  touch:"* marked:'calendar_arrow_image_view'"
  wait_for_none_animating
end

Then /^I check the calendar is opened$/ do
  sleep(2)
  screenshot_and_raise("Calendar is not opened") if query("JTCalendarDayView").count() < 20
end

Then /^I check the calendar is closed$/ do
  sleep(2)
  screenshot_and_raise("Calendar is not closed") if query("JTCalendarDayView").count() > 20
end