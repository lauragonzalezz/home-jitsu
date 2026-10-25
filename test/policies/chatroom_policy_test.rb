require "test_helper"

class ChatroomPolicyTest < ActiveSupport::TestCase
  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @carol = users(:carol)
    @chatroom = Chatroom.create!(name: "chatroom_#{@alice.id}_#{@bob.id}_")
  end

  test "a participant can view the chatroom" do
    assert ChatroomPolicy.new(@alice, @chatroom).show?
    assert ChatroomPolicy.new(@bob, @chatroom).show?
  end

  test "a non-participant cannot view the chatroom" do
    assert_not ChatroomPolicy.new(@carol, @chatroom).show?
  end

  test "anyone can create a chatroom and see their messages" do
    assert ChatroomPolicy.new(@carol, @chatroom).create?
    assert ChatroomPolicy.new(@carol, @chatroom).my_messages?
  end

  test "scope only returns chatrooms the user participates in" do
    other = Chatroom.create!(name: "chatroom_#{@bob.id}_#{@carol.id}_")
    scope = ChatroomPolicy::Scope.new(@alice, Chatroom).resolve
    assert_includes scope, @chatroom
    assert_not_includes scope, other
  end
end
