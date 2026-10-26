class NotificationsController < ApplicationController
  def index
    @notifications = policy_scope(Noticed::Notification)
  end
end
