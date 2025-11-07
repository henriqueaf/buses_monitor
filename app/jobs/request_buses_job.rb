class RequestBusesJob < ApplicationJob
  queue_as :default

  def perform(bus_type:)
    case bus_type
    when :brt
      fetch_brt_buses
    else
      Rails.logger.error("Unknown bus type: #{bus_type}")
    end
  end

  private

  def fetch_brt_buses
    buses = RequestBrtBuses.call

    if buses.present? && buses["veiculos"].any?
      puts "Fetched BRT buses: #{buses["veiculos"].size} buses"
      BrtBusesCache.write(buses["veiculos"])

      puts "Sending broadcast to MapController index page"
      Turbo::StreamsChannel.broadcast_update_to "map_controller_index_page",
        target: "bus-list-input",
        partial: "map/input_buses_list",
        locals: { buses: buses["veiculos"] }
    end
  end
end
