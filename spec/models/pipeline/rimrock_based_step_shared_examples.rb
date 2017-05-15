# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a Rimrock-based step' do

  it 'creates RimrockComputation' do
    expect { described_class.new(patient, user) }.
      to change { RimrockComputation.count }.by(1)
  end

  it 'returns a RimrockComputation object' do
    allow(Rimrock::StartJob).to receive(:perform_later)
    computation = described_class.new(patient, user).run
    expect(computation.class).to eq RimrockComputation
  end

  it 'starts a Rimrock job' do
    expect(Rimrock::StartJob).to receive(:perform_later)
    described_class.new(patient, user).run
  end
end
