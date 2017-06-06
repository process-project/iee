# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe PipelineStep::BloodFlowSimulation do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, procedure_status: :virtual_model_ready) }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a Rimrock-based step'

  it_behaves_like 'a pipeline step'

  it "runs the step only if patient's virtual model is ready" do
    computation = PipelineStep::BloodFlowSimulation.new(patient, user).run
    expect(computation).to be_truthy
  end

  it "raise error if patient's virtual model is not ready yet" do
    patient.not_started!
    expect { PipelineStep::BloodFlowSimulation.new(patient, user).run }.
      to raise_error('Virtual model must be ready to run Blood Flow Simulation')
  end

  it 'creates computation with script returned by generator' do
    script = 'BLOOD FLOW SCRIPT'
    allow(ScriptGenerator::BloodFlow).to receive_message_chain(:new, :call) { script }
    computation = PipelineStep::BloodFlowSimulation.new(patient, user).run
    expect(computation.script).to eq script
  end
end