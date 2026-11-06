require "test_helper"

class PartnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)       # hosts open_mat
    @bob   = users(:bob)         # not the host
    @event = events(:open_mat)   # host: alice
  end

  test "the host can open the invite-partners list for their event" do
    sign_in @alice
    get event_invite_partners_path(@event)
    assert_response :success

    # Renders the host's friends (alice is partnered with bob and carol).
    assert_select ".card-box a[href=?]", user_path(@bob)
    assert_select ".card-box a[href=?]", user_path(users(:carol))
  end

  test "friends already on the guest list are marked invited, with no invite button" do
    sign_in @alice
    get event_invite_partners_path(@event)

    # Both of alice's friends (bob, carol) are already guests of open_mat, so
    # @guests_ids covers them and no invite buttons render.
    assert_select "small", text: "Invited", count: 2
    assert_select "form[action^=?]", "/guests/invite_link", count: 0
  end

  test "a non-host cannot open another user's event invite list" do
    sign_in @bob
    get event_invite_partners_path(@event)
    assert_redirected_to root_path
    assert_equal "You're not allowed to do that.", flash[:alert]
  end

  test "a missing event returns not found rather than erroring on a bad id" do
    sign_in @alice
    assert_raises(ActiveRecord::RecordNotFound) do
      get event_invite_partners_path(event_id: -1)
    end
  end
end
