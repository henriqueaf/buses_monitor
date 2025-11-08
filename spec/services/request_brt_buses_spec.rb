require 'rails_helper'

RSpec.describe RequestBrtBuses do
  let(:service) { described_class.new }
  let(:mock_response_body) do
    {
      "veiculos" => [
        { codigo: "901008", placa: "RIV8A75", linha: "22", latitude: -22.964785, longitude: -43.391878, dataHora: 1762536894000, velocidade: 1.2, id_migracao_trajeto: "8970", sentido: "ida", trajeto: "22 - ALVORADA X JARDIM OCEÂNICO (PARADOR) [IDA]", hodometro: 217397.4, direcao: " ", ignicao: 0, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 },
        { codigo: "901011", placa: "RIV8A74", linha: "22", latitude: -23.006588, longitude: -43.312418, dataHora: 1762536881000, velocidade: 0.3, id_migracao_trajeto: "8971", sentido: "volta", trajeto: "22 - JARDIM OCEÂNICO X ALVORADA (PARADOR) [VOLTA]", hodometro: 231993.7, direcao: 262, ignicao: 1, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 }
      ]
    }.to_json
  end

  describe ".call" do
    it "creates a new instance and calls #call on it" do
      instance = instance_double(RequestBrtBuses)
      allow(RequestBrtBuses).to receive(:new).and_return(instance)
      allow(instance).to receive(:call).and_return({})

      RequestBrtBuses.call

      expect(RequestBrtBuses).to have_received(:new)
      expect(instance).to have_received(:call)
    end
  end

  describe "#initialize" do
    it "creates a Faraday connection with the correct base URL" do
      expect(service.connection).to be_a(Faraday::Connection)
      expect(service.connection.url_prefix.to_s).to eq('https://dados.mobilidade.rio/')
    end
  end

  describe "#call" do
    let(:faraday_connection) { instance_double(Faraday::Connection) }
    let(:response) { instance_double(Faraday::Response) }

    before do
      allow(Faraday).to receive(:new).and_return(faraday_connection)
      allow(faraday_connection).to receive(:get).with('/gps/brt').and_return(response)
    end

    context "when the request is successful" do
      before do
        allow(response).to receive(:success?).and_return(true)
        allow(response).to receive(:body).and_return(mock_response_body)
      end

      it "makes a GET request to /gps/brt" do
        service.call
        expect(faraday_connection).to have_received(:get).with('/gps/brt')
      end

      it "returns parsed JSON data" do
        result = service.call
        expect(result).to be_a(Hash)
        expect(result["veiculos"]).to be_an(Array)
        expect(result["veiculos"].size).to eq(2)
      end

      it "returns the correct structure" do
        result = service.call
        expect(result).to have_key("veiculos")
        expect(result).to eq(JSON.parse(mock_response_body).with_indifferent_access)
      end
    end

    context "when the request fails" do
      before do
        allow(response).to receive(:success?).and_return(false)
      end

      it "returns an empty hash" do
        result = service.call
        expect(result).to eq({})
      end
    end

    context "when a Faraday error occurs" do
      before do
        allow(faraday_connection).to receive(:get).and_raise(Faraday::TimeoutError.new("Connection timeout"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error" do
        service.call
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch buses: Connection timeout/)
      end

      it "returns an empty hash" do
        result = service.call
        expect(result).to eq({})
      end
    end

    context "when a connection error occurs" do
      before do
        allow(faraday_connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("Failed to open TCP connection"))
        allow(Rails.logger).to receive(:error)
      end

      it "logs the connection error" do
        service.call
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch buses: Failed to open TCP connection/)
      end

      it "returns an empty hash" do
        result = service.call
        expect(result).to eq({})
      end
    end
  end

  describe "BASE_URL constant" do
    it "is defined with correct value" do
      expect(RequestBrtBuses::BASE_URL).to eq('https://dados.mobilidade.rio')
    end
  end
end
