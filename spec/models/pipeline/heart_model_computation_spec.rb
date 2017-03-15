# frozen_string_literal: true
require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe Pipeline::HeartModelComputation do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, procedure_status: :after_parameter_estimation) }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a Rimrock-based step'

  it_behaves_like 'a pipeline step'

  it "runs the step only if patient's virtual model is ready" do
    computation = Pipeline::HeartModelComputation.run(patient, user)
    expect(computation).to be_truthy
  end

  it "raise error if patient's virtual model is not ready yet" do
    patient.not_started!
    expect { Pipeline::HeartModelComputation.run(patient, user) }.to raise_error(
      'Heart Model Computation can be run after parameter estimation'
    )
  end

  it 'uses appropriate script generator' do
    expect(HeartModelScriptGenerator).to receive_message_chain(:new, :script)
    Pipeline::HeartModelComputation.run(patient, user)
  end

  it 'creates computation with script returned by generator' do
    script = 'HEART MODEL SCRIPT'
    allow(HeartModelScriptGenerator).to receive_message_chain(:new, :script) { script }
    computation = Pipeline::HeartModelComputation.run(patient, user)
    expect(computation.script).to eq script
  end
end
