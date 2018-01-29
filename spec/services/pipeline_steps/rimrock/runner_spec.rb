# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Rimrock::Runner do
  let(:template_fetcher) do
    fetcher = class_double(Gitlab::GetFile)
    allow(fetcher).to receive_message_chain(:new, :call) { 'script' }

    fetcher
  end

  let(:revision_fetcher) do
    fetcher = class_double(Gitlab::Revision)
    allow(fetcher).to receive_message_chain(:new, :call) { 'revision' }

    fetcher
  end

  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:computation) { create(:rimrock_computation, pipeline_step: '0d_models') }

  subject do
    described_class.new(computation, 'repo', 'file',
                        template_fetcher: template_fetcher,
                        revision_fetcher: revision_fetcher,
                        updater: double(new: updater))
  end

  context 'inputs are available' do
    before do
      create(:data_file,
             patient: computation.pipeline.patient,
             data_type: :parameter_optimization_result)
    end

    it_behaves_like 'runnable step'

    it 'sent notification after computation is started' do
      expect(updater).to receive(:call)

      subject.call
    end
  end
end
