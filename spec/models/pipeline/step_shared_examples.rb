# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a pipeline step' do
  it 'associates created computation with pipeline' do
    computation = described_class.new(pipeline).create
    expect(computation.pipeline).to eq pipeline
  end

  it 'associates created computation with user' do
    computation = described_class.new(pipeline).create
    expect(computation.user).to eq pipeline.user
  end
end

shared_examples 'not ready to run step' do
  it "raise error if patient's virtual model is not ready yet" do
    expect { described_class.new(pipeline).run }.
      to raise_error('Required inputs are not available')
  end

  it 'is not runnable' do
    expect(described_class.new(pipeline).runnable?).to be_falsy
  end
end
