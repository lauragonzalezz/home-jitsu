require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def valid_attributes
    { user: users(:alice), writer: users(:bob), content: "Solid guard game.", rating: 4 }
  end

  test "a review with content, a rating and both users is valid" do
    assert Review.new(valid_attributes).valid?
  end

  test "requires content and a rating" do
    assert_not Review.new(valid_attributes.merge(content: nil)).valid?
    assert_not Review.new(valid_attributes.merge(rating: nil)).valid?
  end

  test "rating must be between 1 and 5" do
    assert_not Review.new(valid_attributes.merge(rating: 0)).valid?
    assert_not Review.new(valid_attributes.merge(rating: 6)).valid?
    (1..5).each do |rating|
      assert Review.new(valid_attributes.merge(rating: rating)).valid?, "#{rating} should be valid"
    end
  end

  test "requires both the reviewed user and the writer" do
    assert_not Review.new(valid_attributes.merge(user: nil, user_id: nil)).valid?
    assert_not Review.new(valid_attributes.merge(writer: nil, writer_id: nil)).valid?
  end
end
