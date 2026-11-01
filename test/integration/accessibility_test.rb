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

  test "the advanced partner search is a real toggle button with labelled fields" do
    sign_in users(:alice)
    get users_path
    assert_response :success

    # The toggle is a real <button> with an accessible name, wired to the
    # controller declaratively (aria-expanded / aria-controls are added at runtime).
    assert_select "button[data-advanced-search-target=toggler][aria-label=?]", "Advanced search"
    assert_select "button[data-advanced-search-target=toggler][data-action=?]", "advanced-search#open"

    # Every advanced field carries a real (visually-hidden) label with a unique id.
    assert_select "label.visually-hidden[for=?]", "advanced-minweight"
    assert_select "input#advanced-minweight"
    assert_select "label.visually-hidden[for=?]", "advanced-belt"
    assert_select "select#advanced-belt"
  end

  test "the back bar is a real button wired to history, not a javascript: link" do
    sign_in users(:alice)
    get new_event_path
    assert_response :success

    assert_select "button.back-bar-back[data-controller=history-back][aria-label=?]", "Go back"
    assert_select "a[href=?]", "javascript:history.back()", count: 0
  end

  test "the attendee see-all control is a real button" do
    # open_mat has carol_accepted as a confirmed guest, so the list renders.
    sign_in users(:alice)
    get event_path(events(:open_mat))
    assert_response :success

    assert_select "button.link-button[data-attendee-list-target=link][data-action=?]", "attendee-list#toggle"
    assert_select "button.link-button[data-attendee-list-target=link]", text: "See all"
    assert_select "#attendee-list[data-attendee-list-target=list]"
  end

  # Pages that used to lead with a back-bar <h2> (or no heading at all) now carry
  # exactly one page <h1>, so the heading outline starts at the right level.
  test "key pages expose exactly one h1" do
    sign_in users(:alice)

    get users_path
    assert_select "h1", count: 1, text: "Find a partner"

    get events_path
    assert_select "h1", count: 1, text: "Find an event"

    get my_events_path
    assert_select "h1", count: 1, text: "My events"

    get user_path(users(:bob))
    assert_select "h1", count: 1, text: "#{users(:bob).first_name} #{users(:bob).last_name}"

    get edit_user_registration_path
    assert_select "h1", count: 1, text: "Edit my profile"
  end
end
