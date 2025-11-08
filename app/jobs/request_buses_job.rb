class RequestBusesJob < ApplicationJob
  queue_as :default

  def perform(bus_type:)
    case bus_type
    when "brt"
      fetch_brt_buses
    else
      Rails.logger.error("Unknown bus type: #{bus_type}")
    end
  end

  private

  def fetch_brt_buses
    buses = RequestBrtBuses.call

    if buses["veiculos"]&.any?
      puts "Fetched BRT buses: #{buses["veiculos"].size} buses"
      BrtBusesCache.write(buses["veiculos"])

      puts "Sending broadcast to MapChannel"
      ActionCable.server.broadcast(
        MapChannel::CHANNEL_KEY_NAME,
        { buses: buses["veiculos"] }
      )
    end
  end
end
