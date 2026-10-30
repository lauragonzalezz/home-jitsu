import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attendee-list"
// Collapses a long attendee list behind a "See all" toggle. The toggle
// reports its state with aria-expanded/aria-controls so it's clear to
// assistive tech whether the rest of the list is shown or hidden.
export default class extends Controller {
  static targets = ["link", "list"];

  connect() {
    // Short lists need no toggle: hide the control and leave the list expanded.
    if (this.listTarget.childElementCount <= 2) {
      this.linkTarget.style.display = "none";
      return;
    }

    this.listTarget.classList.add("hide-attendees");
    this.linkTarget.setAttribute("aria-controls", this.listTarget.id);
    this.linkTarget.setAttribute("aria-expanded", "false");
  }

  // Wired declaratively (data-action="attendee-list#toggle").
  toggle() {
    // classList.toggle returns true when the class is now present (collapsed).
    const collapsed = this.listTarget.classList.toggle("hide-attendees");
    this.linkTarget.textContent = collapsed ? "See all" : "Hide";
    this.linkTarget.setAttribute("aria-expanded", collapsed ? "false" : "true");
  }
}
