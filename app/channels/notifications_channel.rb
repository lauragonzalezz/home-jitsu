class NotificationsChannel < ApplicationCable::Channel
  # One stream per user. Notifiers broadcast to the recipient (see
  # ApplicationNotifier), which matches this per-user stream.
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end
end
