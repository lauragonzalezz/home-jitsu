require "test_helper"

class GuestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob   = users(:bob)
  end

  test "inviting a partner creates the guest and returns to the event's invite list" do
    sign_in @alice
    event = events(:past_mat) # hosted by alice, no guests yet

    assert_difference -> { Guest.count }, 1 do
      post invite_path(event_id: event.id, guest_id: @bob.id)
    end

    guest = Guest.order(:id).last
    assert_equal event.id, guest.event_id
    assert_equal @bob.id, guest.guest_id
    assert_equal "Invited", guest.status
    assert_redirected_to event_invite_partners_path(event.id)
  end

  test "a non-host cannot invite a guest to someone else's event" do
    sign_in @bob # not the host of past_mat (alice is)
    event = events(:past_mat)

    assert_no_difference -> { Guest.count } do
      post invite_path(event_id: event.id, guest_id: users(:carol).id)
    end
    assert_redirected_to root_path
    assert_equal "You're not allowed to do that.", flash[:alert]
  end
end
