require "test_helper"

# The address autocomplete supplies exact coordinates with the address, and the
# model should trust them instead of geocoding again. When coordinates are
# missing (typed by hand, JS off), the model geocodes the address itself.
# test_helper stubs Geocoder to return Boston [42.3601, -71.0589].
class GeocodingTest < ActiveSupport::TestCase
  STUB_LAT = 42.3601

  test "User keeps form-supplied coordinates instead of re-geocoding" do
    user = users(:alice)
    user.update!(address: "5333 Casgrain, Montreal", latitude: 45.5308, longitude: -73.6176)

    assert_in_delta 45.5308, user.reload.latitude, 0.0001
    assert_in_delta(-73.6176, user.longitude, 0.0001)
  end

  test "User geocodes the address when no coordinates are supplied" do
    user = users(:alice)
    user.update!(address: "Somewhere new", latitude: nil, longitude: nil)

    assert_in_delta STUB_LAT, user.reload.latitude, 0.0001
  end

  test "Event keeps form-supplied coordinates instead of re-geocoding" do
    event = events(:open_mat)
    event.update!(address: "5333 Casgrain, Montreal", latitude: 45.5308, longitude: -73.6176)

    assert_in_delta 45.5308, event.reload.latitude, 0.0001
  end

  test "Event geocodes the address when no coordinates are supplied" do
    event = events(:open_mat)
    event.update!(address: "Somewhere new", latitude: nil, longitude: nil)

    assert_in_delta STUB_LAT, event.reload.latitude, 0.0001
  end
end
