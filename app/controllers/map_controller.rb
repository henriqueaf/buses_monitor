class MapController < ApplicationController
  def index
    @buses = JSON.parse(Rails.cache.read('buses_monitor:brt_buses'))
    Rails.logger.info "Loaded #{@buses.size} BRT buses from cache"
  end
end
