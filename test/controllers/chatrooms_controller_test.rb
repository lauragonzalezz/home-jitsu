require "test_helper"

class ChatroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob   = users(:bob)
    @carol = users(:carol)
    @chatroom = chatrooms(:alice_bob)
    sign_in @alice
  end

  test "show renders the conversation for a member" do
    get chatroom_path(@chatroom)
    assert_response :success

    assert_select ".chatroom .messages", 1
    assert_match "Hey Bob, want to roll this weekend?", response.body
    assert_match "For sure, Saturday open mat?", response.body
  end

  test "show wires up the live-chat Stimulus controller" do
    get chatroom_path(@chatroom)
    assert_response :success

    assert_select "[data-controller=?]", "chatroom-subscription"
    assert_select "[data-chatroom-subscription-chatroom-id-value=?]", @chatroom.id.to_s
    assert_select "[data-chatroom-subscription-current-user-id-value=?]", @alice.id.to_s
    assert_select "[data-chatroom-subscription-target=messages]", 1
    assert_select "[data-chatroom-subscription-target=input]", 1
    assert_select "[data-chatroom-subscription-target=button]", 1
  end

  test "show wires the form to the submit-start and submit-end callbacks" do
    get chatroom_path(@chatroom)

    action = css_select("form.d-flex").first["data-action"]
    assert_includes action, "turbo:submit-start->chatroom-subscription#submitStart"
    assert_includes action, "turbo:submit-end->chatroom-subscription#submitEnd"

    input_action = css_select("[data-chatroom-subscription-target=input]").first["data-action"]
    assert_includes input_action, "input->chatroom-subscription#inputChanged"
  end

  test "show renders a hidden send-failure message for screen readers" do
    get chatroom_path(@chatroom)

    error = css_select("[data-chatroom-subscription-target=error]").first
    assert_not_nil error
    assert_equal "alert", error["role"]
    assert_not_nil error["hidden"]
  end

  test "show is forbidden for a user who is not in the room" do
    sign_in @carol
    get chatroom_path(@chatroom)
    assert_redirected_to root_path
    assert_equal "You're not allowed to do that.", flash[:alert]
  end
end
