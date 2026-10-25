require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "protected pages redirect to the sign-in page when logged out" do
    get events_path
    assert_redirected_to new_user_session_path

    get my_events_path
    assert_redirected_to new_user_session_path

    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "signed-in users are not redirected away from protected pages" do
    sign_in users(:alice)
    get my_events_path
    assert_response :success
  end
end
