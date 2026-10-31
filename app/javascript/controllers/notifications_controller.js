import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="notifications"
// Subscribes to the per-user NotificationsChannel and lights up the matching
// footer badge live, so the unread dot appears without a page reload.
export default class extends Controller {
  static targets = ["messages", "notifications"]

  connect() {
    // Only signed-in footers carry the badge targets; without them there's
    // nothing to update (and the cable connection would be rejected anyway).
    if (!this.hasMessagesTarget && !this.hasNotificationsTarget) return

    this.channel = createConsumer().subscriptions.create(
      { channel: "NotificationsChannel" },
      { received: data => this.#markUnread(data) }
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  #markUnread(data) {
    const link = data.badge === "messages"
      ? (this.hasMessagesTarget ? this.messagesTarget : null)
      : (this.hasNotificationsTarget ? this.notificationsTarget : null)

    if (!link || link.classList.contains("new")) return

    link.classList.add("new")
    const label = document.createElement("span")
    label.className = "visually-hidden"
    label.textContent = " (unread)"
    link.appendChild(label)
  }
}
