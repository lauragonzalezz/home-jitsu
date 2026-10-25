require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  def valid_attributes
    { requester: users(:alice), requestee: users(:carol), status: "pending" }
  end

  test "a partner request with both users and a valid status is valid" do
    assert Partner.new(valid_attributes).valid?
  end

  test "requires a requester and a requestee" do
    assert_not Partner.new(valid_attributes.merge(requester: nil, requester_id: nil)).valid?
    assert_not Partner.new(valid_attributes.merge(requestee: nil, requestee_id: nil)).valid?
  end

  test "status must be pending, accepted or rejected" do
    assert_not Partner.new(valid_attributes.merge(status: "ignored")).valid?
    Partner::STATUS.each do |status|
      assert Partner.new(valid_attributes.merge(status: status)).valid?, "#{status} should be valid"
    end
  end

  test "users returns the pair in requester, requestee order" do
    assert_equal [users(:alice), users(:bob)], partners(:alice_bob).users
  end
end
