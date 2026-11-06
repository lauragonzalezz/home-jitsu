class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit::Authorization

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # A failed authorization sends the user back with a flash instead of 500-ing.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name weight height belt years_of_experience address latitude longitude description gender photo training_style])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name weight height belt years_of_experience address latitude longitude description gender photo training_style])
  end

  def set_notifications
    notifications = Noticed::Notification.where(recipient: current_user)
    @unread = notifications.unread
    @read = notifications.read
  end

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def mark_notification_as_read(notification)
    Noticed::Notification.find(notification).mark_as_read! if notification
  end

  private

  def user_not_authorized
    flash[:alert] = "You're not allowed to do that."
    redirect_back fallback_location: root_path
  end

  # Where to center an address search: the coordinates the address autocomplete
  # supplied, or a geocode of the typed query as a fallback. nil when neither
  # resolves. Shared by the users and events index searches.
  def search_coordinates
    if params[:latitude].present? && params[:longitude].present?
      [ params[:latitude].to_f, params[:longitude].to_f ]
    else
      Geocoder.search(params[:query]).first&.coordinates
    end
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  # Parse the combined "field_direction" sort param (e.g. "belt_desc") against
  # an allow-list. Returns [field, direction], falling back to distance
  # ascending for anything missing or unexpected. Shared by the index searches.
  def parse_sort(value, allowed)
    field, _, direction = value.to_s.rpartition("_")
    field = "distance" unless allowed.include?(field)
    direction = "asc" unless %w[asc desc].include?(direction)
    [ field, direction ]
  end

  # Sort a collection by the block's key, always pushing records whose key is
  # nil (no reviews, unranked belt) to the end in both directions. direction is
  # "asc" or "desc".
  def sort_nils_last(collection, direction, &key)
    ranked, unranked = collection.to_a.partition { |item| !key.call(item).nil? }
    ranked = ranked.sort_by(&key)
    ranked.reverse! if direction == "desc"
    ranked + unranked
  end
end
