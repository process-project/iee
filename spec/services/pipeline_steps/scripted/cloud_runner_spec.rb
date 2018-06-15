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
      client = client_double
      expect(client).to receive(:register_initial_config)
      expect(client).to receive(:spawn_appliance_set)
      expect(client).to receive(:spawn_appliance)
      subject.call
    end

    it 'creates computation with script returned by generator' do
      client_double
      computation.assign_attributes(revision: 'revision')
      subject.call
      expect(computation.script).to include 'script payload'
    end
  end

  private

  def client_double
    client = double(Cloud::Client)
    allow(Cloud::Client).to receive(:new).and_return(client)
    allow(client).to receive_messages(
      register_initial_config: 1, spawn_appliance_set: 2, spawn_appliance: 3
    )
    client
  end
end
