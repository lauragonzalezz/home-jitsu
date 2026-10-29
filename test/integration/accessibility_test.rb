require "test_helper"

# Pins the accessibility invariants added in the a11y pass so they don't
# silently regress: document language, the skip link, the main landmark,
# real form labels, accessible names on icon/div controls, and the
# screen-reader name on the otherwise-visual star rating.
class AccessibilityTest < ActionDispatch::IntegrationTest
  test "the sign-in page sets lang, a skip link, a main landmark and labelled inputs" do
    get new_user_session_path
    assert_response :success

    assert_select "html[lang=en]"
    assert_select "a.skip-link[href=?]", "#main-content", text: "Skip to main content"
    assert_select "main#main-content"

    # Inputs carry a real (visually-hidden) label instead of a placeholder only.
    assert_select "label.visually-hidden[for=?]", "user_email"
    assert_select "label.visually-hidden[for=?]", "user_password"
  end

  test "the sign-up form labels every input instead of relying on placeholders" do
    get new_user_registration_path
    assert_response :success

    assert_select "label.visually-hidden[for=?]", "user_first_name"
    assert_select "label.visually-hidden[for=?]", "user_last_name"
    assert_select "label.visually-hidden[for=?]", "user_email"
    # No invalid autocomplete tokens left behind on the free-text fields.
    assert_select "input[autocomplete=weight]", count: 0
    assert_select "input[autocomplete=given-name]"
  end

  test "signed-in chrome exposes the menu and search as real buttons with names" do
    sign_in users(:alice)
    get my_events_path
    assert_response :success

    assert_select "nav[aria-label=Main]"
    assert_select "button[aria-label=?]", "Open menu"
    assert_select "button[aria-label=Search]"
    assert_select "footer nav[aria-label=Primary]"
  end

  test "star ratings expose an accessible name and hide the decorative icons" do
    sign_in users(:bob)
    get user_path(users(:alice))
    assert_response :success

    assert_select "div.stars-container[role=img][aria-label]"
    assert_select "div.stars-active[aria-hidden=true]"
  end

  test "icon-only accept and reject buttons have accessible names" do
    # open_mat is hosted by alice and in the future; bob_pending is a pending
    # RSVP on it, so the host sees the icon-only accept/reject controls.
    sign_in users(:alice)
    get event_path(events(:open_mat))
    assert_response :success

    assert_select "button[aria-label=?]", "Accept #{users(:bob).first_name}"
    assert_select "button[aria-label=?]", "Reject #{users(:bob).first_name}"
  end
end
