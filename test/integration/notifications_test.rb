require "test_helper"

class NotificationsTest < ActionDispatch::IntegrationTest
  test "the notifications page renders a received notification" do
    # carol RSVPs to alice's event, which notifies alice (the host).
    sign_in users(:carol)
    post guests_path, params: { event_id: events(:open_mat).id }

    sign_in users(:alice)
    get notifications_path
    assert_response :success
    assert_select "strong", /would like to join/
  end

  test "my_messages renders when the user has no chatrooms" do
    sign_in users(:alice)
    get my_messages_path
    assert_response :success
  end
end
