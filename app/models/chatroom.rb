class Chatroom < ApplicationRecord
  has_many :messages

  # Notifications generated "about" this chatroom (MessageNotification sets the
  # chatroom as the event record). Replaces noticed 1.x's has_noticed_notifications.
  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy
  has_many :notifications_as_chatroom, through: :noticed_events, source: :notifications

  def other_user(current_user)
    room = self.name
    ids = room.scan(/\d+/).map(&:to_i)
    other_id = ids.select { |id| id != current_user.id }
    user = User.find(other_id[0])
    return user
  end
end
