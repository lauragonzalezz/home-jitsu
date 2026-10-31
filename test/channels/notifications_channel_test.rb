require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  test "subscribes the signed-in user to their own stream" do
    stub_connection current_user: users(:alice)
    subscribe

    assert subscription.confirmed?
    assert_has_stream_for users(:alice)
  end
end
