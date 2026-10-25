require "test_helper"

class EventsFlowTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:alice) }

  test "a signed-in user can create an event and becomes its host" do
    assert_difference "Event.count", 1 do
      post events_path, params: {
        event: {
          title: "Thursday Rolls",
          description: "After-work training.",
          address: "50 Milk St, Boston, MA",
          date: 4.days.from_now
        }
      }
    end

    event = Event.order(:created_at).last
    assert_redirected_to event_path(event)
    assert_equal users(:alice), event.host
    assert_equal "Open", event.status
  end

  test "the host can destroy their own event" do
    event = events(:open_mat) # hosted by alice
    assert_difference "Event.count", -1 do
      delete event_path(event)
    end
    assert_redirected_to events_path
  end

  test "a non-host cannot destroy someone else's event" do
    event = events(:closed_mat) # hosted by bob
    assert_no_difference "Event.count" do
      assert_raises(Pundit::NotAuthorizedError) { delete event_path(event) }
    end
  end
end
