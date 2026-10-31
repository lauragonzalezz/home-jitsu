require "test_helper"

class NotificationBroadcastTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  include ActiveJob::TestHelper

  test "each notifier maps to the right footer badge" do
    assert_equal "notifications", PartnerNotification.new.badge
    assert_equal "notifications", GuestNotification.new.badge
    assert_equal "notifications", ReviewNotification.new.badge
    assert_equal "messages", MessageNotification.new.badge
  end

  test "delivering a notification broadcasts the badge to the recipient's stream" do
    recipient = users(:bob)

    assert_broadcast_on(NotificationsChannel.broadcasting_for(recipient), badge: "notifications") do
      perform_enqueued_jobs do
        PartnerNotification.with(type: "user", message: "Alice invited you", link_to: users(:alice)).deliver(recipient)
      end
    end
  end
end
