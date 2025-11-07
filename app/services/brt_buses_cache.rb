class BrtBusesCache
  CACHE_KEY = "buses_monitor:brt_buses".freeze

  # Read buses array data from cache
  # @return [Array] that contains the list of buses
  def self.read
    cached_data = Rails.cache.read(CACHE_KEY)
    JSON.parse(cached_data || "[]")
  end

  # Write buses array data to cache
  # @param buses [Array] that contains the list of buses
  def self.write(buses)
    Rails.cache.write(CACHE_KEY, JSON.generate(buses))
  end
end
