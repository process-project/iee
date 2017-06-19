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

shared_examples 'ready to run step' do
  include ActiveSupport::Testing::TimeHelpers

  it 'is runnable' do
    expect(described_class.new(pipeline).runnable?).to be_truthy
  end

  it 'set computation start time to now' do
    now = Time.zone.local(2017, 1, 2, 7, 21, 34)
    travel_to now

    computation = described_class.new(pipeline).run

    expect(computation.started_at).to eq now

    travel_back
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
