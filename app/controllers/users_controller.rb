class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def index
    if params[:query].present?
      geocoded_search_results = Geocoder.search(params[:query])
      top_result = geocoded_search_results.first
      @users = policy_scope(User).near(top_result.address, 5)
    else
      @users = policy_scope(User)
    end
  end

  def show
    authorize @user
    set_partner
    @chatroom_name = get_name(@user, current_user)
    @single_chatroom = Chatroom.where(name: @chatroom_name).first
    @average_rating = @user.reviews.average(:rating).round(2) if @user.reviews.exists?
    set_notifications_to_read
  end

  def edit
    authorize @user
    @message = "Edit your profile"
  end

  def update
    authorize @user
    @user.update(user_params)
    redirect_to user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_partner
    set_user
    @partner = Partner.find_by(requestee_id: @user.id, requester_id: current_user.id) ||
               Partner.find_by(requester_id: @user.id, requestee_id: current_user.id)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :weight, :height, :belt,
                                 :years_of_experience, :address, :description, :gender, :photo)
  end

  def get_name(user1, user2)
    user = [user1.id, user2.id].sort
    "private_#{user[0]}_#{user[1]}_"
  end

  def set_notifications_to_read
    current_user.notifications.mark_as_read!
  end
end
