require "test_helper"

# Pins the server-rendered wiring the address autocomplete depends on: the
# controller on the form, the target/action on the address input, and the
# hidden coordinate fields it fills in.
class AddressAutocompleteTest < ActionDispatch::IntegrationTest
  test "the new-event form is wired for address autocomplete" do
    sign_in users(:alice)
    get new_event_path
    assert_response :success

    assert_select "form[data-controller=address-autocomplete]"
    assert_select "input#event_address[data-address-autocomplete-target=input]"
    assert_select "input#event_address[data-action*=?]", "address-autocomplete#search"
    assert_select "input[type=hidden][name=?][data-address-autocomplete-target=latitude]", "event[latitude]"
    assert_select "input[type=hidden][name=?][data-address-autocomplete-target=longitude]", "event[longitude]"
  end

  test "the edit-event form is wired for address autocomplete" do
    sign_in users(:alice)
    get edit_event_path(events(:open_mat))
    assert_response :success

    assert_select "form[data-controller=address-autocomplete]"
    assert_select "input#event_address[data-address-autocomplete-target=input]"
    assert_select "input[type=hidden][name=?][data-address-autocomplete-target=latitude]", "event[latitude]"
  end
end
