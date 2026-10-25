class GuestNotification < Noticed::Event
  # Database-backed only: the record powers the notifications list and the
  # unread badges. Display data lives in params, which the views read through
  # the delegated `notification.params`.
end
