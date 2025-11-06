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

    unless buses.blank?
      puts "Fetched BRT buses: #{buses['veiculos'].size} buses"
      Rails.cache.write('buses_monitor:brt_buses', JSON.generate(buses['veiculos']))
    end
  end
end
