require "test_helper"

class ChatroomTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    # Chatroom names encode the two participants' ids, e.g. "chatroom_1_2_".
    @chatroom = Chatroom.create!(name: "chatroom_#{@alice.id}_#{@bob.id}_")
  end

  test "other_user returns the participant who is not the current user" do
    assert_equal @bob, @chatroom.other_user(@alice)
    assert_equal @alice, @chatroom.other_user(@bob)
  end

  test "a chatroom has many messages" do
    @chatroom.messages.create!(user: @alice, content: "hey")
    @chatroom.messages.create!(user: @bob, content: "oss")
    assert_equal 2, @chatroom.messages.count
  end
end
