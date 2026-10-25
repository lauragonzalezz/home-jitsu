require "test_helper"

class PartnerPolicyTest < ActiveSupport::TestCase
  setup do
    # carol requested alice (pending): alice is the requestee.
    @partner = partners(:carol_alice)
    @requestee = users(:alice)
    @requester = users(:carol)
  end

  test "anyone can create, destroy and list partner requests" do
    policy = PartnerPolicy.new(@requester, @partner)
    assert policy.create?
    assert policy.destroy?
    assert policy.index?
  end

  test "only the requestee can accept or reject a request" do
    assert PartnerPolicy.new(@requestee, @partner).accept?
    assert PartnerPolicy.new(@requestee, @partner).reject?

    assert_not PartnerPolicy.new(@requester, @partner).accept?
    assert_not PartnerPolicy.new(@requester, @partner).reject?
  end
end
