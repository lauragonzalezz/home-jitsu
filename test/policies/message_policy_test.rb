require "test_helper"

class MessagePolicyTest < ActiveSupport::TestCase
  # Messages are currently open: any signed-in user may create one. This test
  # pins that behavior so tightening it later is a deliberate, visible change.
  test "any user can create a message" do
    assert MessagePolicy.new(users(:alice), Message.new).create?
  end
end
