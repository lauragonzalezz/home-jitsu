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

  # The hrefs of the rendered event cards, in display order.
  def listed_event_paths
    css_select("a.card-box").map { |card| card["href"] }
  end

  test "sort by date ascending lists the soonest event first" do
    get events_path(sort: "date_asc")
    paths = listed_event_paths
    # closed_mat is in 2 days, open_mat in a week.
    assert_operator paths.index(event_path(events(:closed_mat))), :<,
                    paths.index(event_path(events(:open_mat)))
  end

  test "sort by date descending flips the order" do
    get events_path(sort: "date_desc")
    paths = listed_event_paths
    assert_operator paths.index(event_path(events(:open_mat))), :<,
                    paths.index(event_path(events(:closed_mat)))
  end

  test "an unexpected sort value falls back to the default order without error" do
    get events_path(sort: "bogus")
    assert_response :success
    assert_includes @response.body, "Sunday Open Mat"
  end

  test "index renders a labelled sort control" do
    get events_path
    assert_select "label[for=sort]", text: "Sort by"
    assert_select "select[name=sort]"
  end
end
