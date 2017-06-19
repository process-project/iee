# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe PipelineStep::BloodFlowSimulation do
  let(:user) { create(:user) }
  let(:pipeline) { create(:pipeline, user: user) }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a pipeline step'

  context 'inputs are available' do
    before do
      create(:data_file, data_type: :fluid_virtual_model, patient: pipeline.patient)
      create(:data_file, data_type: :ventricle_virtual_model, patient: pipeline.patient)
    end

    it_behaves_like 'ready to run step'
    it_behaves_like 'a Rimrock-based ready to run step'

    it 'creates computation with script returned by generator' do
      script = 'BLOOD FLOW SCRIPT'
      allow(ScriptGenerator::BloodFlow).to receive_message_chain(:new, :call) { script }
      computation = PipelineStep::BloodFlowSimulation.new(pipeline).run
      expect(computation.script).to eq script
    end
  end

  context 'inputs are not available' do
    it_behaves_like 'not ready to run step'
  end
end
