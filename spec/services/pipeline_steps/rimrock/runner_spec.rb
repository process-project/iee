# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Rimrock::Runner do
  let(:template_fetcher) do
    fetcher = class_double(Gitlab::GetFile)
    allow(fetcher).to receive(:new).
      with('repo', 'file', anything).
      and_return(double(call: 'script payload'))

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

    it 'starts a Rimrock job' do
      expect(Rimrock::StartJob).to receive(:perform_later)

      subject.call
    end

    it 'creates computation with script returned by generator' do
      computation.assign_attributes(revision: 'revision')

      subject.call

      expect(computation.script).to include 'script payload'
    end

    it 'set job_id to null while restarting computation' do
      computation.update(job_id: 'some_id', revision: 'master')

      subject.call

      expect(computation.job_id).to be_nil
    end
  end
end
