require "test_helper"

class EventTest < ActiveSupport::TestCase
  def valid_attributes
    {
      host: users(:alice),
      title: "Morning Rolls",
      description: "Early session before work.",
      date: 3.days.from_now,
      status: "Open",
      address: "200 Clarendon St, Boston, MA"
    }
  end

  test "a fully specified event is valid" do
    assert Event.new(valid_attributes).valid?
  end

  test "requires a host" do
    assert_not Event.new(valid_attributes.merge(host: nil)).valid?
  end

  test "requires date, title and description" do
    assert_not Event.new(valid_attributes.merge(date: nil)).valid?
    assert_not Event.new(valid_attributes.merge(title: nil)).valid?
    assert_not Event.new(valid_attributes.merge(description: nil)).valid?
  end

  test "status must be Open or Closed" do
    assert_not Event.new(valid_attributes.merge(status: "Cancelled")).valid?
    assert Event.new(valid_attributes.merge(status: "Open")).valid?
    assert Event.new(valid_attributes.merge(status: "Closed")).valid?
  end

  test "geocodes the address on validation" do
    event = Event.new(valid_attributes)
    event.valid?
    assert_equal 42.3601, event.latitude
    assert_equal(-71.0589, event.longitude)
  end

  test "an event has many guests" do
    assert_equal 2, events(:open_mat).guests.size
  end

  test "distance_to measures from the event's coordinates" do
    assert_equal 0, events(:open_mat).distance_to([ events(:open_mat).latitude, events(:open_mat).longitude ])
  end
end
