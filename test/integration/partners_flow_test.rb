require "test_helper"

class PartnersFlowTest < ActionDispatch::IntegrationTest
  test "a user can send a partner request, creating a pending partner and a notification" do
    sign_in users(:carol)

    assert_difference ["Partner.count", "Notification.count"], 1 do
      post partners_path, params: { requester_id: users(:carol).id, requestee_id: users(:bob).id }
    end

    partner = Partner.order(:created_at).last
    assert_response :redirect
    assert_equal users(:carol), partner.requester
    assert_equal users(:bob), partner.requestee
    assert_equal "pending", partner.status
  end

  test "the requestee can accept a pending request" do
    sign_in users(:alice)
    partner = partners(:carol_alice) # carol requested alice

    patch accept_path(users(:carol)) # set_partner looks the request up by the other user's id
    partner.reload
    assert_equal "accepted", partner.status
  end
end
