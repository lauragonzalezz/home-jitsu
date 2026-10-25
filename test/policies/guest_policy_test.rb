require "test_helper"

class GuestPolicyTest < ActiveSupport::TestCase
  # Guest (RSVP/invite) actions are currently open to any signed-in user.
  # Pinned so a future restriction is a deliberate, visible change.
  test "any user can create, invite, destroy, accept and reject" do
    policy = GuestPolicy.new(users(:bob), guests(:bob_pending))
    assert policy.create?
    assert policy.invite?
    assert policy.destroy?
    assert policy.accept?
    assert policy.reject?
  end
end
