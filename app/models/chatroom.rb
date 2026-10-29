class Chatroom < ApplicationRecord
  has_many :messages

  # Notifications generated "about" this chatroom (MessageNotification sets the
  # chatroom as the event record). Replaces noticed 1.x's has_noticed_notifications.
  has_many :noticed_events, as: :record, class_name: "Noticed::Event", dependent: :destroy

  # Noticed::Notification records tied to this chatroom's events. A subquery
  # (rather than a has_many :through) keeps the returned relation join-free, so
  # callers can chain .where(...).unread.update_all(...) safely.
  def notifications_as_chatroom
    Noticed::Notification.where(event_id: noticed_events.select(:id))
  end

  def other_user(current_user)
    room = self.name
    ids = room.scan(/\d+/).map(&:to_i)
    other_id = ids.select { |id| id != current_user.id }
    user = User.find(other_id[0])
    user
  end
end
