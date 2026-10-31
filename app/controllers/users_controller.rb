class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]

  def index
    @users = policy_scope(User)

    if params[:query].present?
      top_result = Geocoder.search(params[:query]).first
      if top_result
        # Use the coordinates we already resolved instead of handing the address
        # string back to .near, which would geocode it a second time.
        @users = @users.near(top_result.coordinates, 5)
      else
        @users = []
      end
    else
      @users = @users.where.not(latitude: nil)
      unless current_user.latitude.nil?
        @users = @users.sort_by { |user| user.distance_to([ current_user.latitude, current_user.longitude ]).round(1) }
      end
    end

    if params[:name].present?
      @users = @users.select { |user| user.first_name.downcase == params[:name].downcase || user.last_name.downcase == params[:name].downcase }
    end

    if params[:minweight].present?
      @users = @users.select { |user| user.weight >= params[:minweight].to_i }
    end

    if params[:maxweight].present?
      @users = @users.select { |user| user.weight <= params[:maxweight].to_i }
    end

    if params[:minheight].present?
      @users = @users.select { |user| user.height >= params[:minheight].to_i }
    end

    if params[:maxheight].present?
      @users = @users.select { |user| user.height <= params[:maxheight].to_i }
    end

    if params[:belt].present?
      @users = @users.select { |user| user.belt == params[:belt] }
    end

    if params[:training_style].present?
      @users = @users.select { |user| user.training_style == params[:training_style] }
    end

    if params[:minyears].present?
      @users = @users.select { |user| user.years_of_experience >= params[:minyears].to_i }
    end

    if params[:maxyears].present?
      @users = @users.select { |user| user.years_of_experience <= params[:maxyears].to_i }
    end

    if params[:gender].present?
      @users = @users.select { |user| user.gender == params[:gender] }
    end
  end

  def show
    authorize @user
    set_partner
    @chatroom_name = get_name(@user, current_user)
    @single_chatroom = Chatroom.where(name: @chatroom_name).first
    @average_rating = @user.reviews.average(:rating).round(2) if @user.reviews.exists?
    mark_notification_as_read(params[:notification_id])
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
    @partner = Partner.between(current_user, @user).first
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :weight, :height, :belt,
                                 :years_of_experience, :address, :latitude, :longitude,
                                 :description, :gender, :photo)
  end

  def get_name(user1, user2)
    user = [ user1.id, user2.id ].sort
    "private_#{user[0]}_#{user[1]}_"
  end
end
