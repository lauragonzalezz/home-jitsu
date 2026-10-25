require "test_helper"

class EventsBrowsingTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:alice) }

  test "the events index renders" do
    get events_path
    assert_response :success
  end

  test "an event show page renders" do
    get event_path(events(:open_mat))
    assert_response :success
  end

  test "the my_events page renders" do
    get my_events_path
    assert_response :success
  end
end
