# register with server
Then /^I start ci server$/ do
  @ci_server.start_in_test_mode
end

# Stop server
Then /^I stop ci server$/ do
  @ci_server.stop
end

# Post json in server
Then /^I load data for calendar$/ do
  data_path = @CI_SERVER_PATH + '/data/' + dir
  arr = {"data/event_2016_07.json"=>"events/2016/07"}
  @ci_server.post_json(arr)
end
