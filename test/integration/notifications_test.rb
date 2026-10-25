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

  test "my_messages renders a chatroom with messages and an unread notification" do
    alice = users(:alice)
    bob = users(:bob)
    chatroom = Chatroom.create!(name: "private_#{[alice.id, bob.id].min}_#{[alice.id, bob.id].max}_")
    chatroom.messages.create!(user: bob, content: "oss")
    # Exercises _chat.html.erb's chat.notifications_as_chatroom lookup.
    MessageNotification.with(record: chatroom, type: "message").deliver(alice)

    sign_in alice
    get my_messages_path
    assert_response :success
  end
end
