# Validate tab bar buttons
Then /^I validate tab bar buttons$/ do
  step 'I wait for new version popup and close it'

  wait_for(WAIT_TIMEOUT) { view_with_mark_exists('Calendar') }

  hash_data_calendar = [
    {"class" => "UITabBarButton", "label" => 'Calendar'},
    {"class" => "UITabBarButtonLabel", "text" => 'Calendar'},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1}
  ]

  hash_data_request = [
    {"class" => "UITabBarButton", "label" => 'Requests'},
    {"class" => "UITabBarButtonLabel", "text" => 'Requests'},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1}
  ]

  hash_data_prime = [
    {"class" => "UITabBarButton", "label" => 'PRIME'},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1},
    {"class" => "UITabBarButtonLabel", "text" => 'PRIME'}
  ]

  hash_data_cityguide = [
    {"class" => "UITabBarButton", "label" => 'City Guide'},
    {"class" => "UITabBarButtonLabel", "text" => 'City Guide'},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1}
  ]

  hash_data_me = [
    {"class" => "UITabBarButton", "label" => 'Me'},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1},
    {"class" => "UITabBarButtonLabel", "text" => 'Me'}
  ]

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data_calendar);
  qr.parse_data

  if !qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'calendar_tab_bar_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end

  qr.set_array(hash_data_request);
  qr.parse_data

  if !qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'requests_tab_bar_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end

  qr.set_array(hash_data_prime);
  qr.parse_data

  if !qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'prime_tab_bar_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end

  qr.set_array(hash_data_cityguide);
  qr.parse_data

  if !qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'city_guide_tab_bar_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end

  qr.set_array(hash_data_me);
  qr.parse_data

  if !qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'me_tab_bar_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end

  wait_for_none_animating
end

# Test tab bar requests badge number data
Then /^I check tab bar Requests badge number is (\d+)$/ do |badge|

  hash_data = [
    {"class" => "UITabBarButton",     "label" => "Requests"},
    {"class" => "UITabBarButtonLabel",  "text" => "Requests"},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1},
    {"class" => "_UIBadgeView",     "alpha" => 1},
    {"class" => "_UIBadgeBackground",   "alpha" => 1},
    {"class" => "UILabel",        "label" => badge}
  ]

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'requests_badge_number_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test tab bar Prime badge number data
Then /^I check tab bar PRIME badge number is (\d+)$/ do |badge|

  hash_data = [
    {"class" => "UITabBarButton",     "label" => "PRIME"},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1},
    {"class" => "UITabBarButtonLabel",  "text" => "PRIME"},
    {"class" => "_UIBadgeView",     "alpha" => 1},
    {"class" => "_UIBadgeBackground",   "alpha" => 1},
    {"class" => "UILabel",        "label" => badge}
  ]

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'tab_bar_Prime_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Test tab bar Prime has no badge data
Then /^I check tab bar PRIME has no badge$/ do

  hash_data = [
    {"class" => "UITabBarButton",     "label" => "PRIME"},
    {"class" => "UITabBarSwappableImageView", "alpha" => 1},
    {"class" => "UITabBarButtonLabel",  "text" => "PRIME"},
    {"class" => "UITabBarButton",     "label" => "City Guide"}
  ]

  qr = ParseQuery.new(query('*'));
  qr.set_array(hash_data);
  qr.parse_data

  unless qr.is_pattern_found then
    qr.print_query_to_file(generate_random_string(header:'tab_bar_no_badge_', ext:'.json'))
    screenshot_and_raise(qr.print_full_status)
  end
end

# Touch selected button
Then /^I select "([^\"]+)" tab$/ do |button|
  wait_for_none_animating
  sleep(1)
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(button) }
  touch("UITabBarButton marked:'#{button}'")
  wait_for_none_animating
  sleep(1)
end
