class RequestBrtBuses
  BASE_URL = 'https://dados.mobilidade.rio'

  def self.call
    new.call
  end

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  attr_reader :connection

  def call
    response = connection.get('/gps/brt')
    if response.success?
      JSON.parse(response.body)
    else
      {}
    end
  rescue Faraday::Error => e
    Rails.logger.error("Failed to fetch buses: #{e.message}")
    {}
  end
end
