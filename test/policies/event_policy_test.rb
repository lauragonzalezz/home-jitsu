require "test_helper"

class EventPolicyTest < ActiveSupport::TestCase
  setup do
    @host = users(:alice)
    @other = users(:bob)
    @event = events(:open_mat) # hosted by alice
  end

  test "anyone can view, list and create events" do
    policy = EventPolicy.new(@other, @event)
    assert policy.show?
    assert policy.my_events?
    assert policy.new?
    assert policy.create?
  end

  test "only the host can edit, update or destroy an event" do
    assert EventPolicy.new(@host, @event).edit?
    assert EventPolicy.new(@host, @event).update?
    assert EventPolicy.new(@host, @event).destroy?

    assert_not EventPolicy.new(@other, @event).edit?
    assert_not EventPolicy.new(@other, @event).update?
    assert_not EventPolicy.new(@other, @event).destroy?
  end

  test "scope resolves to all events" do
    scope = EventPolicy::Scope.new(@host, Event).resolve
    assert_equal Event.count, scope.count
  end
end
