import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="advanced-search"
// Toggles the full-screen advanced-search panel and keeps it accessible:
// the toggle reports its state with aria-expanded, Escape closes the panel,
// and focus moves into the panel on open and back to the toggle on close.
export default class extends Controller {
  static targets = ["toggler", "search"];

  connect() {
    // open is wired declaratively (data-action="advanced-search#open").
    // close and onKeydown are wired by hand: close fires on the shared back-bar
    // link (which shouldn't know about this controller), and onKeydown is a
    // document-level Escape we only want listening while the panel is open.
    this.closeButton = this.searchTarget.querySelector(".back-bar a");
    this.close = this.close.bind(this);
    this.onKeydown = this.onKeydown.bind(this);

    this.togglerTarget.setAttribute("aria-controls", this.searchTarget.id);
    this.togglerTarget.setAttribute("aria-expanded", "false");

    this.closeButton.addEventListener("click", this.close);
  }

  disconnect() {
    this.closeButton.removeEventListener("click", this.close);
    document.removeEventListener("keydown", this.onKeydown);
  }

  open() {
    this.searchTarget.classList.add("d-block");
    this.togglerTarget.setAttribute("aria-expanded", "true");
    document.addEventListener("keydown", this.onKeydown);

    const firstField = this.searchTarget.querySelector("input, select, textarea");
    (firstField || this.closeButton).focus();
  }

  close(event) {
    if (event) event.preventDefault();
    this.searchTarget.classList.remove("d-block");
    this.togglerTarget.setAttribute("aria-expanded", "false");
    document.removeEventListener("keydown", this.onKeydown);
    this.togglerTarget.focus();
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close();
  }
}
