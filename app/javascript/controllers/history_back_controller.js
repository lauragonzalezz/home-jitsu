import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="history-back"
// Backs a real <button> with history navigation so the back bar doesn't
// rely on a javascript: href (which isn't keyboard/AT-friendly).
export default class extends Controller {
  back() {
    window.history.back();
  }
}
