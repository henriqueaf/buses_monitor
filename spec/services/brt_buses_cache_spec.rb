require 'rails_helper'

RSpec.describe BrtBusesCache do
  let(:sample_buses) do
    [
      {codigo:"901008", placa:"RIV8A75", linha:"22", latitude:-22.964785, longitude:-43.391878, dataHora:1762536894000, velocidade:1.2, id_migracao_trajeto:"8970", sentido:"ida", trajeto:"22 - ALVORADA X JARDIM OCEÂNICO (PARADOR) [IDA]", hodometro:217397.4, direcao:" ", ignicao:0, capacidadePeVeiculo:0, capacidadeSentadoVeiculo:0}.with_indifferent_access,
      {codigo:"901011", placa:"RIV8A74", linha:"22", latitude:-23.006588, longitude:-43.312418, dataHora:1762536881000, velocidade:0.3, id_migracao_trajeto:"8971", sentido:"volta", trajeto:"22 - JARDIM OCEÂNICO X ALVORADA (PARADOR) [VOLTA]", hodometro:231993.7, direcao:262, ignicao:1, capacidadePeVeiculo:0, capacidadeSentadoVeiculo:0}.with_indifferent_access
    ]
  end

  describe ".write" do
    it "writes buses data to Rails cache" do
      expect(Rails.cache).to receive(:write).with(
        BrtBusesCache::CACHE_KEY,
        JSON.generate(sample_buses)
      )

      described_class.write(sample_buses)
    end

    it "stores data as JSON string" do
      described_class.write(sample_buses)

      cached_value = Rails.cache.read(BrtBusesCache::CACHE_KEY)
      expect(cached_value).to be_a(String)
      expect(JSON.parse(cached_value)).to eq(sample_buses)
    end

    it "can write an empty array" do
      described_class.write([])

      cached_value = Rails.cache.read(BrtBusesCache::CACHE_KEY)
      expect(JSON.parse(cached_value)).to eq([])
    end
  end

  describe ".read" do
    context "when cache contains data" do
      before do
        Rails.cache.write(BrtBusesCache::CACHE_KEY, JSON.generate(sample_buses))
      end

      it "reads and parses buses data from Rails cache" do
        result = described_class.read
        expect(result).to eq(sample_buses)
      end
    end

    context "when cache is empty" do
      before do
        Rails.cache.delete(BrtBusesCache::CACHE_KEY)
      end

      it "returns an empty array" do
        result = described_class.read
        expect(result).to eq([])
      end
    end
  end

  describe "integration between write and read" do
    it "can write and read back the same data" do
      described_class.write(sample_buses)
      result = described_class.read

      expect(result).to eq(sample_buses)
    end

    it "overwrites previous data when writing new data" do
      old_buses = [{ "id" => "999", "line" => "Old Bus" }]
      described_class.write(old_buses)

      described_class.write(sample_buses)
      result = described_class.read

      expect(result).to eq(sample_buses)
      expect(result).not_to include(old_buses.first)
    end
  end

  describe "CACHE_KEY constant" do
    it "is defined with correct value" do
      expect(BrtBusesCache::CACHE_KEY).to eq("buses_monitor:brt_buses")
    end
  end
end
