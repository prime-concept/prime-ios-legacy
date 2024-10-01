# Test request field data
Then /^I check request without price:$/ do |table|
  wait_for_none_animating
  # Example:
  # | icon    | avia                                          |
  # | name    | NewYork - Paris                               |
  # | detail  | рейс BA 237, 27.06.2015 21:50, LHR терминал 5 |
  request = table.rows_hash
  # TODO: PRIM-742
  # check_element_exists("view:'RequestWithoutPriceCell' descendant view:'*' marked:'#{request[:icon]}'")
  check_element_exists("view:'RequestWithoutPriceCell' descendant view:'*' marked:'#{request[:name]}'")
  check_element_exists("view:'RequestWithoutPriceCell' descendant view:'*' marked:'#{request[:detail]}'")
end

# Test request field data
Then /^I check request with price:$/ do |table|
  wait_for_none_animating
  # Example:
  # | icon    | avia                                          |
  # | name    | NewYork - Paris                               |
  # | detail  | рейс BA 237, 27.06.2015 21:50, LHR терминал 5 |
  request = table.rows_hash
  # TODO: PRIM-742
  # check_element_exists("view:'RequestTableViewCell' descendant view:'*' marked:'#{request[:icon]}'")
  check_element_exists("view:'RequestTableViewCell' descendant view:'*' marked:'#{request[:name]}'")
  check_element_exists("view:'RequestTableViewCell' descendant view:'*' marked:'#{request[:detail]}'")
  check_element_exists("view:'RequestTableViewCell' descendant view:'*' marked:'#{request[:price]}'")
end


# Check request categories

def requestFieldFinder(data)
  string = data['name']
  wait_for(WAIT_TIMEOUT) {element_exists("* marked:'#{string}'")}
  hash_data = [
    # TODO: PRIM-742
    # {"class" => "UIImageView", "id" => data['type']},
    {"class" => "UILabel", "label" => data['name']},
    {"class" => "UILabel", "label" => data['detail']},
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data
  qr
end


# Test to pay request data

Then /^I check a request of type Restaurant:$/ do |table|
  data = table.rows_hash
  data['type'] = 'restaurant_and_clubs'
  qr = requestFieldFinder(data)
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I check a request of type Avia:$/ do |table|
  data = table.rows_hash
  data['type'] = 'task_avia'
  qr = requestFieldFinder(data)
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

Then /^I check a request of type Transfer:$/ do |table|
  data = table.rows_hash
  data['type'] = 'car'
  qr = requestFieldFinder(data)
  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end


# Check all request categories

def getRequestElements
  res = query("*").select { |el| el["class"] == "UIImageView" && !el["id"].nil? }
  screenshot_and_raise "Not any request was found" if res.size == 0
  res
end

Then /^I check all requests type is Restaurant$/ do
  res = getRequestElements
  screenshot_and_raise "Not all requests have Restaurant type\n#{res}" if not res.any? {|el| el["id"].eql?("restaurant_and_clubs")}
end

Then /^I check all requests type is Avia$/ do
  res = getRequestElements
  screenshot_and_raise "Not all requests have Avia type\n#{res}" if not res.any? {|el| el["id"].eql?("task_avia")}
end

Then /^I check all requests type is Transfer$/ do
  res = getRequestElements
  screenshot_and_raise "Not all requests have Transfer type\n#{res}" if not res.any? {|el| el["id"].eql?("car")}
end

Then /^I check (\d+) requests of type Restaurant$/ do |count|
  res = getRequestElements.select {|el| el["id"] == "restaurant_and_clubs"}
  screenshot_and_raise "Expected to see #{count} Restaurant requests, but found #{res.size}" if res.size != count
end


# Test to pay last request data
# depricated
Then /^I check To pay last request:$/ do |table|
  # Example of table:
  # | icon    | avia                                          |
  # | name    | NewYork - Paris                               |
  # | detail  | рейс BA 237, 27.06.2015 21:50, LHR терминал 5 |
  # | price   | 5555 RUR                                      |
  # | action  | Pay                                           |
  request = table.rows_hash
  hash_data = [
    # TODO: PRIM-742
    #{"class" => "UIImageView",  "id" => request['icon']},
    {"class" => "UILabel",    "label" => request['name']},
    {"class" => "UILabel",    "label" => request['detail']},
    {"class" => "UILabel",    "label" => request['price']},
    {"class" => "UIButton",   "label" => request['action']},
    {"class" => "UIButtonLabel", "label" => request['action']},
    {"class" => "_UITableViewCellSeparatorView", "alpha" => 1},
    {"class" => "_UITableViewCellSeparatorView", "alpha" => 1},
    {"class" => "UIButton",   "label" => "More Info"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test In progress and Completed buttons
Then /^I check Requests buttons state$/ do |table|
  # Example
  # | In progress   | selected    |
  # | Completed     | unselected  |
  request = table.rows_hash
  state = {"selected" => true, "unselected" => false}
  hash_data = [
    {"class" => "UISegmentedControl", "alpha" => 1},
    {"class" => "UISegment",    "label" => "In progress", "selected" => state[request['In progress']]},
    {"class" => "UISegmentLabel",   "label" => "In progress"},
    {"class" => "UIImageView",    "alpha" => 1},
    {"class" => "UISegment",    "label" => "Completed",   "selected" => state[request['Completed']]},
    {"class" => "UISegmentLabel",   "label" => "Completed"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'completed_buttons_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test badge number
Then /^I check In Progress badge number is (\d+)$/ do |badge|
  hash_data = [
    {"class" => "UISegment", "label" => "In progress"},
    {"class" => "UISegmentLabel", "label" => "In progress"},
    {"class" => "UIImageView"},
    {"class" => "UISegment", "label" => "Completed"},
    {"class" => "UISegmentLabel", "label" => "Completed"},
    {"class" => "UILabel", "text" => badge}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'badge_number_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end


# Test badge number
Then /^I check Requests tab bar badge number is (\d+)$/ do |badge|
  hash_data = [
    {"class" => "UITabBarButtonLabel", "label" => "Requests"},
    {"class" => "UITabBarSwappableImageView"},
    {"class" => "_UIBadgeView", 'value' => badge},
    {"class" => "UIImageView"},
    {"class" => "UILabel", 'value' => badge}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'pay_badge_number_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end


# Test category item data
Then /^I check Category item:$/ do |table|
  # Example of table:
  # | icon  | hotel       |
  # | name  | Hotel/Trip  |
  # | count | 0           |
  data = table.rows_hash
  string = data['name']
  wait_for(WAIT_TIMEOUT) {element_exists("* marked:'#{string}'")}
  hash_data = [
    # TODO: PRIM-742
    #{"class" => "UIImageView", "id" => data['icon']},
    {"class" => "UILabel", "label" => data['name']},
    {"class" => "UILabel", "label" => data['count']},
    {"class" => "UIButton", "label" => "More Info"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.set_ignore_classes('_UITableViewCellSeparatorView')
  qr.parse_data

  if not qr.is_pattern_found

    hash_data = [
      # TODO: PRIM-742
      # {"class" => "UIImageView", "id" => data['icon']},
      {"class" => "UILabel", "label" => data['name']},
      {"class" => "UILabel", "label" => data['count']},
      {"class" => "UIButton", "label" => "More Info, #{data['name']}, #{data['count']}"}
    ]
    qr.set_array(hash_data);
    qr.set_ignore_classes('_UITableViewCellSeparatorView')
    qr.parse_data
  end

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'category_mismatch_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test request screen data
# depricated
Then /^I am in Requests screen$/ do
  hash_data = [
    {"class" => "UISegment",    "label" => "Booked"},
    {"class" => "UISegmentLabel",   "label" => "Booked"},
    {"class" => "UIImageView",    "alpha" => 1},
    {"class" => "UISegment",    "label" => "To pay"},
    {"class" => "UISegmentLabel",   "label" => "To pay"},
    {"class" => "UIImageView",    "alpha" => 1},
    {"class" => "UISegment",    "label" => "Requests"},
    {"class" => "UISegmentLabel",   "label" => "Requests"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_screen_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test requests navigation buttons data
Then /^I check Requests navigation buttons state:$/ do |table|
  # Example
  # | In progress | selected    |
  # | Completed   | unselected  |
  request = table.rows_hash
  state = {"selected" => true, "unselected" => false}
  hash_data = [
    {"class" => "UISegment", "label" => "In progress", "selected" => state[request['In progress']]},
    {"class" => "UISegmentLabel", "label" => "In progress"},
    {"class" => "UIImageView", "alpha" => 1},
    {"class" => "UISegment", "label" => "Completed", "selected" => state[request['Completed']]},
    {"class" => "UISegmentLabel", "label" => "Completed"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_navigation_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test type of payment screen data
# depricated
Then /^I validate "([^\"]*)" request screen from To Pay tab$/ do |title|
  # Testing empty content of a screen body, as now there is no any data there. In feature, when the content
  # will be available, this test will fail and should be updated.
  check_element_exists("view:'UINavigationBar' descendant view:'UINavigationBar' marked:'#{title}'")
  check_element_exists("view:'UINavigationBar' descendant view:'UIButton' marked:'wechat'")
  check_element_exists("view:'UINavigationBar' descendant view:'UIImageView' marked:'wechat'")
  check_element_exists("view:'UINavigationBar' descendant view:'*' marked:'share'")
end

# Test pay screen data
# depricated
Then /^I validate request payment screen from To Pay tab$/ do
  # Testing empty content of a screen body, as now there is no any data there. In feature, when the content
  # will be available, this test will fail and should be updated.
  hash_data = [
    {"class" => "UIButton","label" => "Back"},
    { "class" => "UIImageView", "id" => "topbar_btn_back"},
    {"class" => "UIButtonLabel","label" => "Back"},
    {"class" => "UINavigationItemView","label" => "Pay"},
    {"class" => "UILabel",  "label" => "Pay"},
    {"class" => "UITabBar", "alpha" => 1},
    {"alpha" => 1, "enabled" => false, "id" => nil, "visible" => 1},
    {"alpha" => 1, "enabled" => false, "id" => nil, "visible" => 1},
    {"class" => "UITabBarButton", "label" => "Calendar"}
  ]
  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'request_screen_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end
