import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="chatroom-subscription"
export default class extends Controller {
  static values = { chatroomId: Number, currentUserId: Number }
  static targets = ["messages", "input", "button", "error"]

  connect() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatroomChannel", id: this.chatroomIdValue },
      { received: data => this.#insertMessageAndScrollDown(data) }
    )
    this.#scrollToBottom()
    this.#syncButton()
  }

  disconnect() {
    this.channel.unsubscribe()
  }

  // input -> the send button is only enabled when there's something to send.
  inputChanged() {
    this.#syncButton()
  }

  // turbo:submit-start -> block a second submit while the first is in flight.
  submitStart() {
    this.buttonTarget.disabled = true
  }

  // turbo:submit-end -> on success clear + refocus; on failure keep the text so
  // the message isn't lost, flag the input and show an error.
  submitEnd(event) {
    if (event.detail.success) {
      event.target.reset()
      this.inputTarget.classList.remove("is-invalid")
      if (this.hasErrorTarget) this.errorTarget.hidden = true
    } else {
      this.inputTarget.classList.add("is-invalid")
      if (this.hasErrorTarget) this.errorTarget.hidden = false
    }
    this.inputTarget.focus()
    this.#syncButton()
  }

  #syncButton() {
    this.buttonTarget.disabled = this.inputTarget.value.trim() === ""
  }

  #scrollToBottom() {
    // Wait a frame so the messages have laid out before we measure scrollHeight.
    requestAnimationFrame(() => {
      this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
    })
  }

  #insertMessageAndScrollDown(data) {
    // Drop the "no messages yet" placeholder once a real message lands.
    this.messagesTarget.querySelector(".empty-state")?.remove()

    // data.message is the server-rendered _message partial, already the full
    // row. The broadcast is shared by both participants and renders received
    // (left), so flip our own messages to the right for this viewer.
    this.messagesTarget.insertAdjacentHTML("beforeend", data.message)
    if (data.sender_id === this.currentUserIdValue) {
      this.messagesTarget.lastElementChild.classList.add("sent")
    }
    this.#scrollToBottom()
  }
}
