# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Webdav::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }
  let(:computation) { create(:webdav_computation, pipeline_step: 'segmentation') }

  subject do
    described_class.new(computation,
                        updater: double(new: updater))
  end

  context 'inputs are available' do
    before do
      create(:data_file,
             patient: computation.pipeline.patient,
             data_type: :image)
    end

    it_behaves_like 'runnable step'

    it 'starts a Webdav job' do
      expect(Webdav::StartJob).to receive(:perform_later)

      subject.call
    end

    it 'changes computation status to :new' do
      subject.call

      expect(computation.status).to eq 'new'
    end
  end
end
