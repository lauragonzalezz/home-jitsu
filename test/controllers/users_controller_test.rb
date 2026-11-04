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

  # The hrefs of the rendered partner cards, in display order.
  def listed_user_paths
    css_select("a.card-box").map { |card| card["href"] }
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

  test "default order is nearest first" do
    get users_path
    paths = listed_user_paths
    # Carol sits almost on top of Alice; Bob is farther away.
    assert_operator paths.index(user_path(@carol)), :<, paths.index(user_path(@bob))
  end

  test "sort by belt ascending lists white before purple" do
    get users_path(sort: "belt_asc")
    paths = listed_user_paths
    assert_operator paths.index(user_path(@carol)), :<, paths.index(user_path(@bob))
  end

  test "sort by belt descending flips the order" do
    get users_path(sort: "belt_desc")
    paths = listed_user_paths
    assert_operator paths.index(user_path(@bob)), :<, paths.index(user_path(@carol))
  end

  test "sort by distance descending lists the farther partner first" do
    get users_path(sort: "distance_desc")
    paths = listed_user_paths
    assert_operator paths.index(user_path(@bob)), :<, paths.index(user_path(@carol))
  end

  test "sort by rating keeps unreviewed partners last in both directions" do
    # Bob has a review; Carol has none, so she sorts last whichever way we go.
    get users_path(sort: "rating_desc")
    desc = listed_user_paths
    assert_operator desc.index(user_path(@bob)), :<, desc.index(user_path(@carol))

    get users_path(sort: "rating_asc")
    asc = listed_user_paths
    assert_operator asc.index(user_path(@bob)), :<, asc.index(user_path(@carol))
  end

  test "an unexpected sort value falls back to the default order without error" do
    get users_path(sort: "bogus")
    assert_response :success
    assert_partner_listed @bob
    assert_partner_listed @carol
  end

  test "index renders a labelled sort control" do
    get users_path
    assert_select "label[for=sort]", text: "Sort by"
    # aria-label keeps the control named even where the visible label is hidden.
    assert_select "select[name=sort][aria-label=?]", "Sort by"
  end
end
