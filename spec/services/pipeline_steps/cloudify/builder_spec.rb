# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Cloudify::Builder do
  let(:pipeline) { create(:pipeline) }

  it 'creates cloudify computation' do
    computation = described_class.new(pipeline, 'cloudify').call

    expect(computation).to be_instance_of CloudifyComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'cloudify'
    expect(computation.pipeline).to eq pipeline
    expect(computation.user).to eq pipeline.user
  end
end
