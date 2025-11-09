require "rails_helper"

RSpec.describe MapChannel, type: :channel do
  let(:cached_buses) do
    [
      { codigo: "901008", placa: "RIV8A75", linha: "22", latitude: -22.964785, longitude: -43.391878, dataHora: 1762536894000, velocidade: 1.2, id_migracao_trajeto: "8970", sentido: "ida", trajeto: "22 - ALVORADA X JARDIM OCEÂNICO (PARADOR) [IDA]", hodometro: 217397.4, direcao: " ", ignicao: 0, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 },
      { codigo: "901011", placa: "RIV8A74", linha: "22", latitude: -23.006588, longitude: -43.312418, dataHora: 1762536881000, velocidade: 0.3, id_migracao_trajeto: "8971", sentido: "volta", trajeto: "22 - JARDIM OCEÂNICO X ALVORADA (PARADOR) [VOLTA]", hodometro: 231993.7, direcao: 262, ignicao: 1, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 }
    ]
  end

  describe "#subscribed" do
    before do
      allow(BrtBusesCache).to receive(:read).and_return(cached_buses)
    end

    it "successfully subscribes to the map controller channel" do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from(MapChannel::CHANNEL_KEY_NAME)
    end

    it "calls BrtBusesCache.read to retrieve buses" do
      subscribe

      expect(BrtBusesCache).to have_received(:read)
    end

    it "transmits the cached buses upon subscription" do
      subscribe

      expect(transmissions.last).to eq({ buses: cached_buses }.with_indifferent_access)
    end
  end

  describe "CHANNEL_KEY_NAME constant" do
    it "has the correct value" do
      expect(MapChannel::CHANNEL_KEY_NAME).to eq("map_controller_channel")
    end
  end
end
