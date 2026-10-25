require "test_helper"

class ReviewPolicyTest < ActiveSupport::TestCase
  # Reviews are currently open: any signed-in user may write one. Pinned so a
  # future restriction is a deliberate, visible change.
  test "any user can start and create a review" do
    policy = ReviewPolicy.new(users(:bob), Review.new)
    assert policy.new?
    assert policy.create?
  end
end
