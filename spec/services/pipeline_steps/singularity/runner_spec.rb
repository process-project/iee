# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Singularity::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:container_registry) { create(:container_registry) }

  let(:computation) do
    create(:singularity_computation,
           pipeline_step: 'singularity_placeholder_step',
           container_registry: container_registry)
  end

  let(:container_name) { 'lolcow' }
  let(:container_tag) { 'latest' }

  subject do
    described_class.new(computation, container_registry.registry_url, container_name, container_tag,
                        updater: double(new: updater))
  end

  context 'container step running' do
    it_behaves_like 'runnable step'

    it 'starts a Rimrock job' do
      expect(Rimrock::StartJob).to receive(:perform_later)

      subject.call
    end

    it 'creates computation with script returned by singularity script generator' do
      subject.call

      expect(computation.script).to include container_registry.registry_url +
                                            container_name +
                                            ':' +
                                            container_tag
    end

    it 'set job_id to null while restarting computation' do
      computation.update_attributes(job_id: 'some_id')

      subject.call

      expect(computation.job_id).to be_nil
    end
  end
end
