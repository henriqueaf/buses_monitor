class MapChannel < ApplicationCable::Channel
  CHANNEL_KEY_NAME = "map_controller_channel"

  def subscribed
    stream_from CHANNEL_KEY_NAME

    buses = BrtBusesCache.read
    transmit({ buses: buses })
  end
end
