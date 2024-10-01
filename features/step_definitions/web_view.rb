Then /^I should see "([^\"]*)" in WebView$/ do |text|
  wait_for_element_exists("WKWebView css:'*' textContent:'#{text}'", timeout: 20)
end

Then /^I touch "([^\"]*)" in WebView$/ do |text|
  wait_tap("WKWebView css:'*' textContent:'#{text}'")
  wait_for_web_page_to_load
end

Then /^I should see back item in WebView$/ do
  wait_for_element_exists("WKWebView css:'*' class:'back_to_link'", timeout: 20)
end

Then /^I press back in WebView$/ do
  wait_tap("WKWebView css:'*' class:'back_to_link'")
  wait_for_web_page_to_load
end

Then /^I press close in WebView$/ do
  wait_tap("WKWebView css:'*' class:'menu_close_btn'")
  wait_for_web_page_to_load
end

Then /^I should see menu item in WebView$/ do
  wait_for_element_exists("WKWebView css:'*' class:'menu_link'", timeout: 20)
end

Then /^I press menu in WebView$/ do
  wait_tap("WKWebView css:'*' class:'menu_link'")
  wait_for_web_page_to_load
end

Then /^I should see search item in WebView$/ do
  wait_for_element_exists("WKWebView css:'*' class:'find_link'", timeout: 20)
end

Then /^I press search in WebView$/ do
  wait_tap("WKWebView css:'*' class:'city_finder'")
  wait_for_web_page_to_load
end

Then /^I close City Guide menu if opened$/ do
  sleep(STEP_PAUSE)
  if (element_exists("WKWebView css:'*' class:'menu_close_btn'"))
    wait_tap("WKWebView css:'*' class:'menu_close_btn'")
    wait_for_web_page_to_load
  end
end

Then /^I validate city page in WebView$/ do
  wait_for_element_exists("WKWebView css:'*' class:'menu_link'")
  if (element_exists("WKWebView css:'*' class:'back_to_link'"))
    check_element_exists("WKWebView css:'*' class:'headerTitle'")
    check_element_exists("WKWebView css:'*' class:'find_link'")
    check_element_exists("WKWebView css:'*' class:'map_link'")
  else
    check_element_exists("WKWebView css:'*' class:'city_finder'")
    check_element_exists("WKWebView css:'*' class:'geo_detection'")
  end
end

Then /^I validate menu in City Guide$/ do
  wait_for_element_exists("WKWebView css:'*' class:'main_menu slideout-menu'")
  check_element_exists("WKWebView css:'*' class:'menu_tabs'")
  check_element_exists("WKWebView css:'*' class:'menu_profile'")
  check_element_exists("WKWebView css:'*' class:'main_menu_item'")
  check_element_exists("WKWebView css:'*' class:'menu_tab menu_tab_active'")
end

Then /^I scroll (up|down) to see "([^\"]+)" in WebView$/ do |dir, expected_mark|
  30.times do
    q = query("WKWebView css:'*' textContent:'#{expected_mark}'")
    break if not q.empty?
    swipe dir, force: :strong
    sleep(STEP_PAUSE)
  end
  sleep(STEP_PAUSE)
end

Then /^I wait until page load$/ do
  wait_for_web_page_to_load
end