require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice) # Blue belt, 65kg, 165cm, 3y, Female, Gi, geocoded
    @bob   = users(:bob)   # Purple belt, 80kg, 180cm, 6y, Male, Both, geocoded
    @carol = users(:carol) # White belt, 58kg, 160cm, 1y, Female, No-gi, geocoded
    sign_in @alice
  end

  # A rendered partner card links to the user via the .card-box anchor.
  def assert_partner_listed(user)
    assert_select "a.card-box[href=?]", user_path(user)
  end

  def refute_partner_listed(user)
    assert_select "a.card-box[href=?]", user_path(user), count: 0
  end

  test "index with no query lists other geocoded partners and excludes self" do
    get users_path
    assert_response :success

    assert_partner_listed @bob
    assert_partner_listed @carol
    refute_partner_listed @alice
  end

  test "belt filter narrows the list to matching partners" do
    get users_path(belt: "Purple")
    assert_response :success

    assert_partner_listed @bob
    refute_partner_listed @carol
  end

  test "minimum weight filter excludes lighter partners" do
    get users_path(minweight: 70)
    assert_response :success

    assert_partner_listed @bob
    refute_partner_listed @carol
  end

  test "training style filter narrows the list" do
    get users_path(training_style: "No-gi")
    assert_response :success

    assert_partner_listed @carol
    refute_partner_listed @bob
  end

  test "address query geocodes and lists nearby partners" do
    # The test geocoder stub resolves any query to Boston, where the fixtures sit.
    get users_path(query: "Boston, MA")
    assert_response :success

    assert_partner_listed @bob
    assert_partner_listed @carol
  end

  test "address query with no geocoding result returns an empty list without error" do
    Geocoder::Lookup::Test.add_stub("nowhere-xyz", [])

    get users_path(query: "nowhere-xyz")
    assert_response :success

    refute_partner_listed @bob
    refute_partner_listed @carol
  end

  test "address query centers on supplied coordinates, not a geocode of the text" do
    # Far-away coordinates (Montreal). If the search uses them, no Boston fixtures
    # fall within range; if it ignored them and geocoded "Boston, MA", the stub
    # would resolve to Boston and list everyone. Emptiness proves the coords win.
    get users_path(query: "Boston, MA", latitude: 45.5308, longitude: -73.6176)
    assert_response :success

    refute_partner_listed @bob
    refute_partner_listed @carol
  end

  test "index still renders when the current user has no coordinates" do
    @alice.update_columns(latitude: nil, longitude: nil)

    get users_path
    assert_response :success
    # Locatable partners are still shown; we just can't sort by distance.
    assert_partner_listed @bob
  end
end
