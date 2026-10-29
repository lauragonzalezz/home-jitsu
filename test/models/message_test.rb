require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @chatroom = Chatroom.create!(name: "chatroom_#{@alice.id}_#{@bob.id}_")
    @message = @chatroom.messages.create!(user: @alice, content: "hello")
  end

  test "requires content" do
    assert_not Message.new(chatroom: @chatroom, user: @alice, content: nil).valid?
  end

  test "sender? is true only for the user who wrote the message" do
    assert @message.sender?(@alice)
    assert_not @message.sender?(@bob)
  end

  test "joined_users returns the users encoded in the chatroom name" do
    assert_equal [ @alice, @bob ], @message.joined_users
  end
end
