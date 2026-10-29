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
    assert_equal [ users(:alice), users(:bob) ], partners(:alice_bob).users
  end

  test "between finds the partnership whichever user sent the request" do
    partnership = partners(:alice_bob) # alice requested bob
    assert_equal partnership, Partner.between(users(:alice), users(:bob)).first
    assert_equal partnership, Partner.between(users(:bob), users(:alice)).first
  end

  test "between accepts ids as well as records" do
    assert_equal partners(:alice_bob), Partner.between(users(:alice).id, users(:bob).id).first
  end

  test "between is empty when the two users have no partnership" do
    assert_empty Partner.between(users(:bob), users(:carol))
  end
end
