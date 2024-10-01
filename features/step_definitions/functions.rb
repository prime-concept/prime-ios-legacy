# Wait 1s untile text appear and report

def check_element(name)
  10.times do |i|
    j = 0.1 * i
    res = element_exists("view text: '#{name}'")
    return 1 if res == true
    sleep(0.1)
  end
  return 0
end

def getCalendarDay(shift)
  n = Date.today + shift
  n.strftime("%d").to_i
end

def wait_for_web_page_to_load
	sleep(STEP_PAUSE)
	30.times do
		q = query("WKWebView css:'CENTER'")
		break if q.empty?
		sleep(STEP_PAUSE)
	end
	sleep(3)
	touch("UILabel marked: 'OK'") unless query("UILabel marked:'OK'").empty?
end
