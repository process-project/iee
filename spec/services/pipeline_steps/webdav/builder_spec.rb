# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Webdav::Builder do
  let(:pipeline) { create(:pipeline) }

  it 'creates webdav computation' do
    computation = described_class.new(pipeline, 'webdav').call

    expect(computation).to be_instance_of WebdavComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'webdav'
    expect(computation.pipeline).to eq pipeline
    expect(computation.output_path).to eq pipeline.outputs_dir
    expect(computation.user).to eq pipeline.user
  end
end
