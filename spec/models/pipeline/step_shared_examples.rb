# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a pipeline step' do
  it 'associates created computation with user' do
    computation = Pipeline::BloodFlowSimulation.run(patient, user)
    expect(computation.patient).to eq patient
  end

  it 'associates created computation with user' do
    computation = Pipeline::BloodFlowSimulation.run(patient, user)
    expect(computation.user).to eq user
  end
end
