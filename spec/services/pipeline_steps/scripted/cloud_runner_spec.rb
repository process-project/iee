# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Scripted::CloudRunner do
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

  let(:computation) do
    create(:scripted_computation, pipeline_step: '0d_models', deployment: 'cloud')
  end

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

    it 'submits a cloud request' do
      expect_any_instance_of(Cloud::Client).to receive(:register_initial_config)
      expect_any_instance_of(Cloud::Client).to receive(:spawn_appliance)
      subject.call
    end

    it 'creates computation with script returned by generator' do
      computation.assign_attributes(revision: 'revision')
      expect_any_instance_of(Cloud::Client).to receive(:register_initial_config)
      expect_any_instance_of(Cloud::Client).to receive(:spawn_appliance)

      subject.call

      expect(computation.script).to include 'script payload'
    end
  end
end
