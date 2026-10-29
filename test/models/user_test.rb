require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_attributes
    {
      first_name: "Dana",
      last_name: "Reis",
      email: "dana@example.com",
      password: "password123",
      weight: 70,
      height: 170,
      belt: "White",
      years_of_experience: 2,
      address: "10 Downing St, Boston, MA",
      gender: "Other",
      training_style: "Gi"
    }
  end

  test "a user with all required attributes is valid" do
    assert User.new(valid_attributes).valid?
  end

  test "requires first and last name" do
    assert_not User.new(valid_attributes.merge(first_name: nil)).valid?
    assert_not User.new(valid_attributes.merge(last_name: nil)).valid?
  end

  test "weight must be present, 2 to 4 digits and positive" do
    assert_not User.new(valid_attributes.merge(weight: nil)).valid?
    assert_not User.new(valid_attributes.merge(weight: 5)).valid?      # 1 digit
    assert_not User.new(valid_attributes.merge(weight: 12345)).valid?  # 5 digits
    assert User.new(valid_attributes.merge(weight: 70)).valid?
  end

  test "height must be present, 2 to 4 digits and positive" do
    assert_not User.new(valid_attributes.merge(height: nil)).valid?
    assert_not User.new(valid_attributes.merge(height: 9)).valid?
    assert User.new(valid_attributes.merge(height: 170)).valid?
  end

  test "belt must be one of the allowed belts" do
    assert_not User.new(valid_attributes.merge(belt: "Red")).valid?
    User::BELTS.each do |belt|
      assert User.new(valid_attributes.merge(belt: belt)).valid?, "#{belt} should be valid"
    end
  end

  test "gender and training_style must be in their allowed lists" do
    assert_not User.new(valid_attributes.merge(gender: "Unknown")).valid?
    assert_not User.new(valid_attributes.merge(training_style: "Freestyle")).valid?
  end

  test "years_of_experience cannot be negative" do
    assert_not User.new(valid_attributes.merge(years_of_experience: -1)).valid?
    assert User.new(valid_attributes.merge(years_of_experience: 0)).valid?
  end

  test "email must be present and unique" do
    assert_not User.new(valid_attributes.merge(email: nil)).valid?
    assert_not User.new(valid_attributes.merge(email: users(:alice).email)).valid?
  end

  test "partnerships combine requested and received partners" do
    # alice requested bob (accepted) and carol requested alice (pending)
    assert_equal 2, users(:alice).partnerships.size
    assert_includes users(:alice).partnerships, partners(:alice_bob)
    assert_includes users(:alice).partnerships, partners(:carol_alice)
  end

  test "friends returns the other user of each partnership, deduplicated" do
    friends = users(:alice).friends
    assert_equal [ users(:bob), users(:carol) ].sort_by(&:id), friends.sort_by(&:id)
  end

  test "distance_to measures from the user's coordinates" do
    assert_equal 0, users(:alice).distance_to([ users(:alice).latitude, users(:alice).longitude ])
  end
end
