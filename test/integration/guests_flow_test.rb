require "test_helper"

class GuestsFlowTest < ActionDispatch::IntegrationTest
  test "a user can RSVP to an event, creating a pending guest and notifying the host" do
    sign_in users(:carol)
    event = events(:closed_mat) # hosted by bob

    assert_difference ["Guest.count", "Notification.count"], 1 do
      post guests_path, params: { event_id: event.id }
    end

    guest = Guest.order(:created_at).last
    assert_redirected_to event_path(event)
    assert_equal users(:carol), guest.guest
    assert_equal "Pending", guest.status
  end
end
