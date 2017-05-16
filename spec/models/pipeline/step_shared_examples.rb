# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a pipeline step' do
  it 'associates created computation with user' do
    computation = described_class.new(patient, user).run
    expect(computation.patient).to eq patient
  end

  it 'associates created computation with user' do
    computation = described_class.new(patient, user).run
    expect(computation.user).to eq user
  end
end
