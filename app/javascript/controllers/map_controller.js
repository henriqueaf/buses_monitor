import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="map"
export default class MapController extends Controller {
  static RIO_DE_JANEIRO_COORDINATES = [-22.9228, -43.4643];

  static values = {
    buses: String
  }

  initialize() {
    this.map = L.map('map').setView(MapController.RIO_DE_JANEIRO_COORDINATES, 11);
    this.featureGroup = null;
  }

  connect() {
    this.#initializeMapLayer();
    this.#subscribeToMapChannel();
  }

  disconnect() {
    this.channel.unsubscribe()
  }

  fitMapToMarkers() {
    this.map.fitBounds(this.featureGroup.getBounds().pad(0.2));
  }

  #subscribeToMapChannel() {
    this.channel = consumer.subscriptions.create("MapChannel", {
      received: data => this.#handleBusesUpdated(data.buses)
    });
  }

  #handleBusesUpdated(busArray) {
    const filteredBusArray = this.#filterBusesWithEngineOn(busArray);
    this.#createBusMarkers(filteredBusArray);
  }

  #filterBusesWithEngineOn(buses) {
    return buses.filter(bus => bus.ignicao === 1);
  }

  #initializeMapLayer() {
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);
  }

  #createBusMarkers(busArray) {
    if (!busArray || busArray.length === 0) return;

    const markers = [];

    busArray.forEach(bus => {
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
