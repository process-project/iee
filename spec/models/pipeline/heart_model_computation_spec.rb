# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe PipelineStep::HeartModelCalculation do
  let(:user) { create(:user) }
  let(:pipeline) { create(:pipeline, user: user) }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a pipeline step'

  context 'inputs are available' do
    before { create(:data_file, data_type: :estimated_parameters, patient: pipeline.patient) }

    it_behaves_like 'ready to run step'
    it_behaves_like 'a Rimrock-based ready to run step'

    it 'creates computation with script returned by generator' do
      script = 'HEART MODEL SCRIPT'
      allow(ScriptGenerator::HeartModel).to receive_message_chain(:new, :call) { script }
      computation = described_class.new(pipeline).run
      expect(computation.script).to eq script
    end
  end

  context 'inputs are not available' do
    it_behaves_like 'not ready to run step'
  end
end
