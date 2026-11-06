require "test_helper"

class GuestPolicyTest < ActiveSupport::TestCase
  # Self-RSVP and the guest's own responses stay open to any signed-in user.
  test "create, destroy, accept and reject stay open to any signed-in user" do
    policy = GuestPolicy.new(users(:bob), guests(:bob_pending))
    assert policy.create?
    assert policy.destroy?
    assert policy.accept?
    assert policy.reject?
  end

  # Inviting others is the host's action; everyone else self-RSVPs via #create.
  test "only the event host can invite guests" do
    guest = guests(:bob_pending) # on open_mat, hosted by alice
    assert GuestPolicy.new(users(:alice), guest).invite?
    assert_not GuestPolicy.new(users(:bob), guest).invite?
  end
end
