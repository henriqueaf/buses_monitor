import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bus-list"
export default class extends Controller {
  static values = {
    buses: String
  }

  connect() {
    // Using data-bus-list-buses-value attribute
    const busArray = JSON.parse(this.busesValue);

    // setTimeout to ensure the map is initialized before dispatching the event
    setTimeout(() => {
      this.dispatch("busesUpdated", { detail: { busArray: busArray } });
    }, 1000);
  }
}
