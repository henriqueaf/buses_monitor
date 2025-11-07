class MapController < ApplicationController
  def index
    @buses = BrtBusesCache.read
  end
end
