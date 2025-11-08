import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class MapController extends Controller {
  static RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

  initialize() {
    this.busArray = [];
    this.map = L.map('map').setView(MapController.RIO_DE_JANEIRO_COORDINATES, 11);
    this.featureGroup = null;
  }

  connect() {
    this.#initializeMapLayer();
  }

  handleBusesUpdated(event) {
    this.busArray = event.detail.busArray;
    this.#createBusMarkers();
  }

  #initializeMapLayer() {
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);
  }

  #createBusMarkers() {
    if (!this.busArray || this.busArray.length === 0) return;

    const markers = [];

    this.busArray.forEach(bus => {
      const marker = L.marker([bus.latitude, bus.longitude])
        .bindPopup(`Trajeto: ${bus.trajeto}`);

      markers.push(marker);
    });

    this.#clearFeatureGroup();
    this.#addMarkersToMap(markers);
  }

  #addMarkersToMap(markers) {
    this.featureGroup = L.featureGroup(markers).addTo(this.map);
  }

  fitMapToMarkers() {
    this.map.fitBounds(this.featureGroup.getBounds().pad(0.2));
  }

  #clearFeatureGroup() {
    if (this.featureGroup) {
      this.featureGroup.clearLayers();
      this.featureGroup.remove();
    }
  }
}
