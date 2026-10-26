class MessageNotification < Noticed::Event
  # Database-backed only. `record` is the chatroom, which lets a chatroom look
  # up its own unread notifications (see Chatroom#notifications_as_chatroom).
  # Real-time chat delivery is handled directly in MessagesController, not here.
end
