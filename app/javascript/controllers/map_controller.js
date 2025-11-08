import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="map"
export default class MapController extends Controller {
  static RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

  static values = {
    buses: String
  }

  initialize() {
    this.busArray = [];
    this.map = L.map('map').setView(MapController.RIO_DE_JANEIRO_COORDINATES, 11);
    this.featureGroup = null;
  }

  connect() {
    this.#initializeMapLayer();
    this.#initializeConsumerSubscription();

    // This value is comming from the data-map-buses-value attribute
    const busListInitialValue = JSON.parse(this.busesValue);
    this.#handleBusesUpdated(busListInitialValue);
  }

  disconnect() {
    this.channel.unsubscribe()
  }

  fitMapToMarkers() {
    this.map.fitBounds(this.featureGroup.getBounds().pad(0.2));
  }

  #initializeConsumerSubscription() {
    this.channel = consumer.subscriptions.create("MapChannel", {
      received: data => this.#handleBusesUpdated(data.buses)
    });
  }

  #handleBusesUpdated(buses) {
    this.busArray = buses;
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

  #clearFeatureGroup() {
    if (this.featureGroup) {
      this.featureGroup.clearLayers();
      this.featureGroup.remove();
    }
  }
}
