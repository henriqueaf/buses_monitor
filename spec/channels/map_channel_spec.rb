require "rails_helper"

RSpec.describe MapChannel, type: :channel do
  describe "#subscribed" do
    it "successfully subscribes to the map controller channel" do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from(MapChannel::CHANNEL_KEY_NAME)
    end
  end

  describe "CHANNEL_KEY_NAME constant" do
    it "has the correct value" do
      expect(MapChannel::CHANNEL_KEY_NAME).to eq("map_controller_channel")
    end
  end
end
