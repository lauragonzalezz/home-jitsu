require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
    @other = users(:bob)
  end

  test "anyone can view a profile and the public listings" do
    policy = UserPolicy.new(@other, @user)
    assert policy.show?
    assert policy.invite_partners_list?
    assert policy.my_events?
  end

  test "a user can only edit or update their own profile" do
    assert UserPolicy.new(@user, @user).edit?
    assert UserPolicy.new(@user, @user).update?

    assert_not UserPolicy.new(@other, @user).edit?
    assert_not UserPolicy.new(@other, @user).update?
  end
end
