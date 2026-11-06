require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    @alice = users(:alice)
    @chatroom = chatrooms(:alice_bob)
    sign_in @alice
  end

  test "create saves the message and answers head :ok for the live insert" do
    assert_difference -> { @chatroom.messages.count }, 1 do
      post chatroom_messages_path(@chatroom), params: { message: { content: "On my way" } }
    end
    assert_response :ok
    assert_empty response.body

    message = @chatroom.messages.order(:created_at).last
    assert_equal "On my way", message.content
    assert_equal @alice, message.user
  end

  test "create broadcasts the rendered message to the chatroom" do
    assert_broadcasts(ChatroomChannel.broadcasting_for(@chatroom), 1) do
      post chatroom_messages_path(@chatroom), params: { message: { content: "Oss" } }
    end
  end

  test "create rejects a blank message without saving" do
    assert_no_difference -> { @chatroom.messages.count } do
      post chatroom_messages_path(@chatroom), params: { message: { content: "" } }
    end
    assert_response :unprocessable_entity
  end
end
