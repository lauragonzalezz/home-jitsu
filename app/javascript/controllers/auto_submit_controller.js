import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
// Submits the surrounding form as soon as a control changes, so picking a sort
// order applies immediately without a separate button. Wired declaratively
// with data-action="change->auto-submit#submit" on the <select>.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
