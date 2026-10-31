require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "identifies the signed-in user from the Warden session" do
    warden = Struct.new(:user).new(users(:alice))
    connect env: { "warden" => warden }
    assert_equal users(:alice), connection.current_user
  end

  test "rejects a connection with no signed-in user" do
    assert_reject_connection { connect }
  end
end
