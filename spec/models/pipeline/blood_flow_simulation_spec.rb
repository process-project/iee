# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe Pipeline::BloodFlowSimulation do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, procedure_status: :virtual_model_ready) }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a Rimrock-based step'

  it_behaves_like 'a pipeline step'

  it "runs the step only if patient's virtual model is ready" do
    computation = Pipeline::BloodFlowSimulation.run(patient, user)
    expect(computation).to be_truthy
  end

  it "raise error if patient's virtual model is not ready yet" do
    patient.not_started!
    expect { Pipeline::BloodFlowSimulation.run(patient, user) }
      .to raise_error('Virtual model must be ready to run Blood Flow Simulation')
  end

  it 'uses appropriate script generator' do
    expect(BloodFlowScriptGenerator).to receive_message_chain(:new, :script)
    Pipeline::BloodFlowSimulation.run(patient, user)
  end

  it 'creates computation with script returned by generator' do
    script = 'BLOOD FLOW SCRIPT'
    allow(BloodFlowScriptGenerator).to receive_message_chain(:new, :script) { script }
    computation = Pipeline::BloodFlowSimulation.run(patient, user)
    expect(computation.script).to eq script
  end
end
