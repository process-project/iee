# frozen_string_literal: true

require 'rails_helper'

shared_examples 'pipeline step builder' do
  it 'associates created computation with pipeline' do
    computation = subject.builder_for(pipeline, {}).call
    expect(computation.pipeline).to eq pipeline
  end

  it 'associates created computation with user' do
    computation = subject.builder_for(pipeline, {}).call
    expect(computation.user).to eq pipeline.user
  end
end
