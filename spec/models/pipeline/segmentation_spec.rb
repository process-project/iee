# frozen_string_literal: true

require 'rails_helper'
require 'models/pipeline/webdav_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe PipelineStep::Segmentation do
  let(:user) { create(:user) }
  let(:pipeline) { create(:pipeline, user: user) }
  let(:computation) { described_class.create(pipeline, {}) }

  before do
    allow(Webdav::StartJob).to receive(:perform_later)
  end

  it_behaves_like 'a pipeline step'

  context 'inputs are available' do
    before { create(:data_file, data_type: :image, patient: pipeline.patient) }

    it_behaves_like 'ready to run step'
    it_behaves_like 'a Webdav-based ready to run step'
  end

  context 'inputs are not available' do
    it_behaves_like 'not ready to run step'
  end
end
