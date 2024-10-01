##############################################################################
# swipe, scroll

# Swipe, depending on screen size
def swipe_screen(dir = "right", swipe_type = "startup_swipe" )
  case dir
  when 'left'
    swipe dir, \
      :query => "scrollView index: 0", \
      :offset => { \
                   :x => fit_to_screen(swipe_type)[:x], \
                   :y => 0 \
                   }, \
      :"swipe-delta" => { \
                          :horizontal => { \
                                           :dx => fit_to_screen(swipe_type)[:dx], \
                                           :dy => 0 \
                                           } \
                          }
  when 'right'
    swipe dir, \
      :query => "scrollView index: 0", \
      :offset => { \
                   :x => -fit_to_screen(swipe_type)[:x], \
                   :y => 0}, \
      :"swipe-delta" => { \
                          :horizontal => { \
                                           :dx => fit_to_screen(swipe_type)[:dx], \
                                           :dy => 0 \
                                           } \
                          }
      end
end

# Swipe screen left
Then /^I swipe startup screen$/ do
  swipe_screen("left")
  sleep(STEP_PAUSE)
end

# Swipe screen left or right
Then /^I swipe screen to (left|right)$/ do |dir|
  swipe_screen(dir)
  sleep(STEP_PAUSE)
end

# Find text by swipping the screen
Then /^I swipe calendar (left|right) to find "([^\"]+)"$/ do |dir, expected_mark|
  # FIXME(PRIM-487):[CI] Add method to detect loading process on screen)
  30.times do
    break if element_exists("* text:'#{expected_mark}'")
    swipe_screen(dir, "calendar_swipe")
    sleep(STEP_PAUSE)
  end
end

# Find text splash screen by swipping the screen
Then /^I swipe (left|right) splash screen to find "([^\"]+)"$/ do |dir, expected_mark|
  10.times do
    break if element_exists("* text:'#{expected_mark}'")
    swipe_screen(dir)
    sleep(STEP_PAUSE)
  end
  sleep(STEP_PAUSE)
end

# Find text request content by swipping the screen
Then /^I swipe (up|down) request content to find "([^\"]+)"$/ do |dir, expected_mark|
  10.times do
    break if element_exists("* text:'#{expected_mark}'")
    swipe dir, force: :normal
    sleep(STEP_PAUSE)
  end
  swipe dir, force: :normal
end

# Touch text by scrolling a list
Then /^I select "([^\"]+)" in city list$/ do |expected_mark|
  scroll_to_row("scrollView", 5) if expected_mark == "Armenia"
  sleep(STEP_PAUSE)
  check_element expected_mark
  touch("label marked: '#{expected_mark}'")
  sleep(STEP_PAUSE)
end

# Find delete button by swipe
Then /^I wait to see "([^\"]+)" then swipe left to find delete$/ do |expected_mark|
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists(expected_mark) }
  swipe('left', { offset: { x: 300 }, query: "* marked:'#{expected_mark}'" })
  wait_for(WAIT_TIMEOUT) { view_with_mark_exists("Delete") }
end


# Find text request content by scrolling the screen
Then /^I scroll (up|down) to find "([^\"]+)"$/ do |dir, expected_mark|
  10.times do
    q = query("* text:'#{expected_mark}'")
    break if not q.empty?
    scroll("tableView", dir)
    sleep(STEP_PAUSE)
  end

  case dir
  when 'up'
    swipe :down,  force: :light
  when 'down'
    swipe :up,  force: :light
  end
  sleep(STEP_PAUSE)
end

Then /^I scroll (up|down) on screen$/ do |dir|
  swipe(dir)
  wait_for_none_animating
end
