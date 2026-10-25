require "test_helper"

class GuestTest < ActiveSupport::TestCase
  def valid_attributes
    { event: events(:open_mat), guest: users(:bob), status: "Pending" }
  end

  test "a guest with an event, a user and a valid status is valid" do
    assert Guest.new(valid_attributes).valid?
  end

  test "requires an event and a guest user" do
    assert_not Guest.new(valid_attributes.merge(event: nil, event_id: nil)).valid?
    assert_not Guest.new(valid_attributes.merge(guest: nil, guest_id: nil)).valid?
  end

  test "status must be one of the allowed values" do
    assert_not Guest.new(valid_attributes.merge(status: "Maybe")).valid?
    Guest::STATUS.each do |status|
      assert Guest.new(valid_attributes.merge(status: status)).valid?, "#{status} should be valid"
    end
  end
end
