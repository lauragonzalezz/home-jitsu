import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  }

  // Fallback view (the app's home region) when there are no markers to show,
  // so an empty result set renders a sensible map instead of a blank ocean.
  static DEFAULT_CENTER = [ -71.0589, 42.3601 ]
  static DEFAULT_ZOOM = 10
  // A single point in fitBounds snaps to maxZoom; this reads better.
  static SINGLE_MARKER_ZOOM = 13

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/lauragonzalezz/clbnukovw000m14n1surhjkm5",
      center: this.constructor.DEFAULT_CENTER,
      zoom: this.constructor.DEFAULT_ZOOM
    })

    // Surface tile/token failures instead of leaving a silently blank map.
    this.map.on("error", (event) => {
      console.warn("Mapbox error:", event.error?.message || event)
    })

    this.#addMarkersToMap()
    this.#fitMapToMarkers()
  }

  // Only markers with real coordinates. A missing geocode leaves lat/lng null,
  // which would otherwise break bounds/markers.
  get validMarkers() {
    return this.markersValue.filter(
      (marker) => Number.isFinite(marker.lng) && Number.isFinite(marker.lat)
    )
  }

  #fitMapToMarkers() {
    const markers = this.validMarkers

    // Nothing to show: keep the default view set at init (no fitBounds, which
    // throws on empty bounds).
    if (markers.length === 0) return

    if (markers.length === 1) {
      this.map.setCenter([ markers[0].lng, markers[0].lat ])
      this.map.setZoom(this.constructor.SINGLE_MARKER_ZOOM)
      return
    }

    const bounds = new mapboxgl.LngLatBounds()
    markers.forEach((marker) => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }

  #addMarkersToMap() {
    this.validMarkers.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window)

      const mapMarker = new mapboxgl.Marker({ color: "#8F5DD0" })
        .setLngLat([ marker.lng, marker.lat ])
        .setPopup(popup)
        .addTo(this.map)

      // Mapbox markers are plain divs: make them focusable, named and operable
      // by keyboard so they aren't invisible to assistive tech.
      const element = mapMarker.getElement()
      element.setAttribute("role", "button")
      element.setAttribute("tabindex", "0")
      if (marker.title) element.setAttribute("aria-label", marker.title)
      element.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault()
          mapMarker.togglePopup()
        }
      })
    })
  }
}
