import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
// Accessible address autocomplete backed by the Mapbox Geocoding v6 forward
// endpoint. Picking a suggestion fills the address field and the hidden
// latitude/longitude, so the server stores Mapbox's exact coordinates without a
// second geocode. Typing by hand clears the coordinates, so the model geocodes
// the typed address itself (the Nominatim fallback from the partner-search fix).
export default class extends Controller {
  static targets = ["input", "latitude", "longitude"]
  static values = { token: String }

  connect() {
    this.suggestions = []
    this.activeIndex = -1
    this.isOpen = false
    this.#buildListbox()

    this.inputTarget.setAttribute("role", "combobox")
    this.inputTarget.setAttribute("aria-autocomplete", "list")
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.setAttribute("aria-controls", this.listbox.id)

    this.onDocClick = this.#onDocClick.bind(this)
    document.addEventListener("click", this.onDocClick)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocClick)
    clearTimeout(this.debounce)
  }

  // data-action input->address-autocomplete#search
  search() {
    // Any manual edit invalidates a previously picked coordinate pair, so the
    // server re-geocodes the typed address instead of trusting stale coords.
    this.#clearCoordinates()

    const query = this.inputTarget.value.trim()
    clearTimeout(this.debounce)
    if (query.length < 3 || !this.tokenValue) {
      this.#close()
      return
    }
    this.debounce = setTimeout(() => this.#fetchSuggestions(query), 250)
  }

  // data-action keydown->address-autocomplete#onKeydown
  onKeydown(event) {
    if (!this.isOpen) return
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.#move(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.#move(-1)
        break
      case "Enter":
        if (this.activeIndex >= 0) {
          event.preventDefault()
          this.#choose(this.activeIndex)
        }
        break
      case "Escape":
        this.#close()
        break
    }
  }

  async #fetchSuggestions(query) {
    const url = new URL("https://api.mapbox.com/search/geocode/v6/forward")
    url.searchParams.set("q", query)
    url.searchParams.set("autocomplete", "true")
    url.searchParams.set("limit", "5")
    url.searchParams.set("access_token", this.tokenValue)

    try {
      const response = await fetch(url)
      if (!response.ok) return this.#close()
      const data = await response.json()
      this.suggestions = (data.features || [])
        .map(feature => ({
          label: feature.properties?.full_address || feature.properties?.name || "",
          coordinates: feature.geometry?.coordinates || []
        }))
        .filter(s => s.label && s.coordinates.length === 2)
      this.#render()
    } catch {
      this.#close()
    }
  }

  #render() {
    this.listbox.innerHTML = ""
    this.activeIndex = -1

    if (this.suggestions.length === 0) return this.#close()

    this.suggestions.forEach((suggestion, index) => {
      const option = document.createElement("li")
      option.id = `${this.listbox.id}-opt-${index}`
      option.setAttribute("role", "option")
      option.className = "address-suggestion"
      option.textContent = suggestion.label
      // mousedown (not click) so the choice lands before the input blurs.
      option.addEventListener("mousedown", event => {
        event.preventDefault()
        this.#choose(index)
      })
      this.listbox.appendChild(option)
    })
    this.#open()
  }

  #choose(index) {
    const suggestion = this.suggestions[index]
    if (!suggestion) return

    this.inputTarget.value = suggestion.label
    const [lng, lat] = suggestion.coordinates
    if (this.hasLatitudeTarget) this.latitudeTarget.value = lat
    if (this.hasLongitudeTarget) this.longitudeTarget.value = lng
    this.#close()
  }

  #move(delta) {
    const options = Array.from(this.listbox.children)
    if (options.length === 0) return

    this.activeIndex = (this.activeIndex + delta + options.length) % options.length
    options.forEach((option, index) => option.classList.toggle("active", index === this.activeIndex))

    const active = options[this.activeIndex]
    this.inputTarget.setAttribute("aria-activedescendant", active.id)
    active.scrollIntoView({ block: "nearest" })
  }

  #clearCoordinates() {
    if (this.hasLatitudeTarget) this.latitudeTarget.value = ""
    if (this.hasLongitudeTarget) this.longitudeTarget.value = ""
  }

  #buildListbox() {
    const wrapper = document.createElement("div")
    wrapper.className = "address-autocomplete"
    this.inputTarget.parentNode.insertBefore(wrapper, this.inputTarget)
    wrapper.appendChild(this.inputTarget)

    this.listbox = document.createElement("ul")
    this.listbox.id = `address-suggestions-${Math.random().toString(36).slice(2, 8)}`
    this.listbox.className = "address-suggestions"
    this.listbox.setAttribute("role", "listbox")
    this.listbox.hidden = true
    wrapper.appendChild(this.listbox)
  }

  #open() {
    this.listbox.hidden = false
    this.isOpen = true
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  #close() {
    this.listbox.hidden = true
    this.isOpen = false
    this.activeIndex = -1
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  #onDocClick(event) {
    if (!this.element.contains(event.target)) this.#close()
  }
}
