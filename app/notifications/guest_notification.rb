class GuestNotification < ApplicationNotifier
  # The record powers the notifications list and the unread badges. Display data
  # lives in params, which the views read through the delegated
  # `notification.params`. Lights up the Notifications badge (the default).
end
