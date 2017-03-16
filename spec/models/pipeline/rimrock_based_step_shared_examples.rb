# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a Rimrock-based step' do
  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  it 'creates RimrockComputation' do
    expect { Pipeline::BloodFlowSimulation.run(patient, user) }.
      to change { RimrockComputation.count }.by(1)
  end

  it 'returns a RimrockComputation object' do
    computation = Pipeline::BloodFlowSimulation.run(patient, user)
    expect(computation.class).to eq RimrockComputation
  end

  it 'starts a Rimrock job' do
    expect(Rimrock::StartJob).to receive(:perform_later)
    Pipeline::BloodFlowSimulation.run(patient, user)
  end
end
