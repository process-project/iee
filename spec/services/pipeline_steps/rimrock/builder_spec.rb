# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Rimrock::Builder do
  let(:pipeline) { create(:pipeline) }

  it 'creates rimrock computation' do
    computation = described_class.new(pipeline, 'rimrock',
                                      tag_or_branch: 'my-branch').call

    expect(computation).to be_instance_of RimrockComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'rimrock'
    expect(computation.pipeline).to eq pipeline
    expect(computation.tag_or_branch).to eq 'my-branch'
    expect(computation.user).to eq pipeline.user
  end
end
