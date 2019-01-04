# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Singularity::Builder do
  let(:pipeline) { create(:pipeline) }

  it 'creates singularity computation' do
    computation = described_class.new(pipeline,
                                      'singularity',
                                      'shub://',
                                      'vsoch/hello-world',
                                      'latest').call

    expect(computation).to be_instance_of SingularityComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'singularity'
    expect(computation.pipeline).to eq pipeline
    expect(computation.container_name).to eq 'vsoch/hello-world'
    expect(computation.registry_url).to eq 'shub://'
    expect(computation.container_tag).to eq 'latest'
    expect(computation.user).to eq pipeline.user
  end
end
