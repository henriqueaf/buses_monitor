import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class MapController extends Controller {
  static RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

  initialize() {
    this.busArray = [];
    this.map = null;
  }

  connect() {
    this.#initializeMap();
  }

  handleBusesUpdated(event) {
    this.busArray = event.detail.busArray;
    this.#createBusMarkers();
  }

  #initializeMap() {
    this.map = L.map('map').setView(MapController.RIO_DE_JANEIRO_COORDINATES, 11);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);
  }

  #createBusMarkers() {
    if (!this.busArray) return;

    const markers = [];

    this.busArray.forEach(bus => {
      const marker = L.marker([bus.latitude, bus.longitude]).addTo(this.map)
        .bindPopup(`Trajeto: ${bus.trajeto}`);

      markers.push(marker);
    });

    const fg = L.featureGroup(markers).addTo(this.map);
    this.map.fitBounds(fg.getBounds());
  }
}
