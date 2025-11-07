require 'rails_helper'

RSpec.describe RequestBusesJob, type: :job do
  subject(:job) { described_class.new }
  let(:mock_buses_response) do
    {
      "veiculos" => [
        {codigo:"901008", placa:"RIV8A75", linha:"22", latitude:-22.964785, longitude:-43.391878, dataHora:1762536894000, velocidade:1.2, id_migracao_trajeto:"8970", sentido:"ida", trajeto:"22 - ALVORADA X JARDIM OCEÂNICO (PARADOR) [IDA]", hodometro:217397.4, direcao:" ", ignicao:0, capacidadePeVeiculo:0, capacidadeSentadoVeiculo:0},
        {codigo:"901011", placa:"RIV8A74", linha:"22", latitude:-23.006588, longitude:-43.312418, dataHora:1762536881000, velocidade:0.3, id_migracao_trajeto:"8971", sentido:"volta", trajeto:"22 - JARDIM OCEÂNICO X ALVORADA (PARADOR) [VOLTA]", hodometro:231993.7, direcao:262, ignicao:1, capacidadePeVeiculo:0, capacidadeSentadoVeiculo:0}
      ]
    }
  end

  describe "#perform" do
    context "when bus_type is :brt" do
      before do
        allow(RequestBrtBuses).to receive(:call).and_return(mock_buses_response)
        allow(BrtBusesCache).to receive(:write)
        allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)
      end

      it "calls RequestBrtBuses.call to fetch data" do
        job.perform(bus_type: :brt)
        expect(RequestBrtBuses).to have_received(:call)
      end

      it "writes buses data to cache when buses are present" do
        expect(BrtBusesCache).to receive(:write).with(mock_buses_response["veiculos"])
        job.perform(bus_type: :brt)
      end

      it "broadcasts update to Turbo streams when buses are present" do
        expect(Turbo::StreamsChannel).to receive(:broadcast_update_to).with(
          "map_controller_index_page",
          target: "bus-list-input",
          partial: "map/input_buses_list",
          locals: { buses: mock_buses_response["veiculos"] }
        )
        job.perform(bus_type: :brt)
      end

      context "when RequestBrtBuses returns nil" do
        before do
          allow(RequestBrtBuses).to receive(:call).and_return(nil)
        end

        it "does not write to cache" do
          expect(BrtBusesCache).not_to receive(:write)
          job.perform(bus_type: :brt)
        end

        it "does not broadcast update" do
          expect(Turbo::StreamsChannel).not_to receive(:broadcast_update_to)
          job.perform(bus_type: :brt)
        end

        it "enqueues the job" do
          expect {
            described_class.perform_later(bus_type: :brt)
          }.to have_enqueued_job(RequestBusesJob)
        end
      end

      context "when RequestBrtBuses returns empty veiculo array" do
        before do
          allow(RequestBrtBuses).to receive(:call).and_return({ "veiculos" => [] })
        end

        it "does not write to cache" do
          expect(BrtBusesCache).not_to receive(:write)
          job.perform(bus_type: :brt)
        end

        it "does not broadcast update" do
          expect(Turbo::StreamsChannel).not_to receive(:broadcast_update_to)
          job.perform(bus_type: :brt)
        end
      end
    end

    context "when bus_type is unknown" do
      it "logs an error" do
        expect(Rails.logger).to receive(:error).with("Unknown bus type: invalid_type")
        job.perform(bus_type: :invalid_type)
      end

      it "does not call RequestBrtBuses" do
        expect(RequestBrtBuses).not_to receive(:call)
        job.perform(bus_type: :invalid_type)
      end
    end
  end

  describe "job queue" do
    it "is queued on the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
