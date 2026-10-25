require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  test "the sign-in page renders" do
    get new_user_session_path
    assert_response :success
  end

  test "signing in with valid credentials redirects into the app" do
    post user_session_path, params: {
      user: { email: users(:alice).email, password: "password123" }
    }
    assert_redirected_to root_path
  end

  test "signing in with a wrong password leaves the user unauthenticated" do
    post user_session_path, params: {
      user: { email: users(:alice).email, password: "wrong-password" }
    }
    # Still locked out of protected pages.
    get my_events_path
    assert_redirected_to new_user_session_path
  end

  test "signing out returns the user to a logged-out state" do
    sign_in users(:alice)
    delete destroy_user_session_path
    get my_events_path
    assert_redirected_to new_user_session_path
  end
end
