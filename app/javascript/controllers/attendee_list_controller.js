import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attendee-list"
// Collapses a long attendee list behind a "See all" toggle. The toggle
// reports its state with aria-expanded/aria-controls so it's clear to
// assistive tech whether the rest of the list is shown or hidden.
export default class extends Controller {
  static targets = ["link", "list"];

  connect() {
    const count = this.listTarget.childElementCount;

    if (count <= 2) {
      this.linkTarget.style.display = "none";
      return;
    }

    this.listTarget.classList.add("hide-attendees");
    this.linkTarget.setAttribute("aria-controls", this.listTarget.id);
    this.linkTarget.setAttribute("aria-expanded", "false");

    this.toggle = this.toggle.bind(this);
    this.linkTarget.addEventListener("click", this.toggle);
  }

  disconnect() {
    this.linkTarget.removeEventListener("click", this.toggle);
  }

  toggle(event) {
    event.preventDefault();
    // classList.toggle returns true when the class is now present (collapsed).
    const collapsed = this.listTarget.classList.toggle("hide-attendees");
    this.linkTarget.textContent = collapsed ? "See all" : "Hide";
    this.linkTarget.setAttribute("aria-expanded", collapsed ? "false" : "true");
  }
}
