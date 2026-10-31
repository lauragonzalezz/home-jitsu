class ApplicationNotifier < Noticed::Event
  # Live, in-app delivery: broadcast a tiny signal over Action Cable so the
  # footer badge lights up without a reload. The database record (the
  # notifications list and the unread counts) is created by noticed regardless,
  # so this is purely additive to the existing behavior.
  deliver_by :action_cable do |config|
    config.channel = "NotificationsChannel"
    config.message = :cable_payload
  end

  # The payload the browser receives. Streamed to the recipient (noticed's
  # default stream), which matches NotificationsChannel's per-user stream.
  def cable_payload(_notification)
    { badge: badge }
  end

  # Which footer badge to light up. MessageNotification overrides this.
  def badge
    "notifications"
  end
end
