ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Keep the geocoder completely offline in tests. Both User and Event geocode
# their address after validation, which would otherwise hit Nominatim over the
# network and make the suite slow, flaky and unusable in CI.
Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [{ "coordinates" => [42.3601, -71.0589], "address" => "Boston, MA, USA" }]
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Lets request tests authenticate with `sign_in(user)` without driving the
  # Devise login form (which would render the full asset-pipeline layout).
  include Devise::Test::IntegrationHelpers
end
