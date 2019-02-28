# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Singularity::Builder do
  let(:pipeline) { create(:pipeline) }

  it 'creates singularity computation with proper container_registry' do
    container_registry_url = 'shub://'
    computation = described_class.new(pipeline,
                                      'singularity',
                                      container_registry_url,
                                      'vsoch/hello-world',
                                      'latest').call

    expect(computation).to be_instance_of SingularityComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'singularity'
    expect(computation.pipeline).to eq pipeline
    expect(computation.container_name).to eq 'vsoch/hello-world'
    expect(computation.container_registry.registry_url).to eq container_registry_url
    expect(computation.container_tag).to eq 'latest'
    expect(computation.user).to eq pipeline.user
  end

  it "doesn't create double records in container_registry table" do
    builder = described_class.new(pipeline,
                                  'singularity',
                                  'shub://',
                                  'vsoch/hello-world',
                                  'latest')
    computation = builder.call
    test_registry_url = computation.container_registry.registry_url
    builder.call

    expect(ContainerRegistry.where(registry_url: test_registry_url).count).to eq 1
  end
end