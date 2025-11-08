require 'rails_helper'

RSpec.describe "Maps", type: :request do
  describe "GET /index" do
    let(:cached_buses) do
      [
        { codigo: "901008", placa: "RIV8A75", linha: "22", latitude: -22.964785, longitude: -43.391878, dataHora: 1762536894000, velocidade: 1.2, id_migracao_trajeto: "8970", sentido: "ida", trajeto: "22 - ALVORADA X JARDIM OCEÂNICO (PARADOR) [IDA]", hodometro: 217397.4, direcao: " ", ignicao: 0, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 },
        { codigo: "901011", placa: "RIV8A74", linha: "22", latitude: -23.006588, longitude: -43.312418, dataHora: 1762536881000, velocidade: 0.3, id_migracao_trajeto: "8971", sentido: "volta", trajeto: "22 - JARDIM OCEÂNICO X ALVORADA (PARADOR) [VOLTA]", hodometro: 231993.7, direcao: 262, ignicao: 1, capacidadePeVeiculo: 0, capacidadeSentadoVeiculo: 0 }
      ]
    end

    context "when cache exists" do
      before do
        allow(BrtBusesCache).to receive(:read).and_return(cached_buses)
      end

      it "returns a successful response" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "assigns @buses with data from the cache" do
        get root_path
        expect(assigns(:buses)).to eq(cached_buses)
      end

      it "calls BrtBusesCache.read to retrieve buses" do
        get root_path
        expect(BrtBusesCache).to have_received(:read)
      end

      it "renders the index template" do
        get root_path
        expect(response).to render_template(:index)
      end
    end

    context "when cache is empty" do
      before do
        allow(BrtBusesCache).to receive(:read).and_return([])
      end

      it "assigns an empty array to @buses" do
        get root_path
        expect(assigns(:buses)).to eq([])
      end
    end
  end
end
