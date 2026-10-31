class MessageNotification < ApplicationNotifier
  # `record` is the chatroom, which lets a chatroom look up its own unread
  # notifications (see Chatroom#notifications_as_chatroom). Real-time chat
  # delivery is handled directly in MessagesController; this notifier only
  # powers the Messages badge, so it lights that one up instead of the default.
  def badge
    "messages"
  end
end
