require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:alice)
  end

  test "index shows upcoming events in the list and on the map" do
    get events_path
    assert_response :success

    assert_includes @response.body, "Sunday Open Mat"
    markers = css_select("#map").first["data-map-markers-value"]
    assert_includes markers, "Sunday Open Mat"
  end

  test "index hides past events from both the list and the map markers" do
    get events_path
    assert_response :success

    # past_mat happened a week ago: not in the card list...
    assert_not_includes @response.body, "Last Month Open Mat"
    # ...and not plotted on the map either (the bug this fixes).
    markers = css_select("#map").first["data-map-markers-value"]
    assert_not_includes markers, "Last Month Open Mat"
  end
end
