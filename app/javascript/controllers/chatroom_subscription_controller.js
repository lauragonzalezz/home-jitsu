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

  #buildMessageElement(currentUserIsSender, message) {
    return `
      <div class="message-row d-flex ${this.#justifyClass(currentUserIsSender)}">
        <div class="${this.#userStyleClass(currentUserIsSender)}">
          ${message}
        </div>
      </div>
    `
  }
  #justifyClass(currentUserIsSender) {
    return currentUserIsSender ? "justify-content-end" : "justify-content-start"
  }
  #userStyleClass(currentUserIsSender) {
    return currentUserIsSender ? "sender-style" : "receiver-style"
  }
  #insertMessageAndScrollDown(data) {
    // Logic to know if the sender is the current_user
    const currentUserIsSender = this.currentUserIdValue === data.sender_id

    // Creating the whole message from the `data.message` String
    const messageElement = this.#buildMessageElement(currentUserIsSender, data.message)

    // Inserting the `message` in the DOM
    this.messagesTarget.insertAdjacentHTML("beforeend", messageElement)
    this.#scrollToBottom()
  }
}
