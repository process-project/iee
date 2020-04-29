# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Singularity::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:singularity_pipeline) do
    create(:pipeline, flow: 'singularity_placeholder_pipeline')
  end

  let(:compute_site) do
    create(:compute_site, name: 'krk')  # TODO: it calls a Lobcder::Service to get uc_root -> isolate tests
  end

  let(:computation) do
    create(:singularity_computation,
           pipeline: singularity_pipeline,
           pipeline_step: 'singularity_placeholder_step',
           container_name: 'test_name',
           container_tag: 'test_tag',
           compute_site: compute_site)
  end

  let!(:singularity_script_blueprint) do
    create(:singularity_script_blueprint,
           container_name: computation.container_name,
           container_tag: computation.container_tag,
           script_blueprint: 'test script',
           compute_site: compute_site)
  end

  subject do
    described_class.new(computation,
                        updater: double(new: updater))
  end

  context 'container step running' do
    it_behaves_like 'runnable step'

    it 'starts a Rimrock job' do
      expect(Rimrock::StartJob).to receive(:perform_later)
      subject.call
    end

    it 'creates singularity computation script' do
      subject.call

      expect(computation.script).to_not be_empty
    end

    it 'set job_id to null while restarting computation' do
      computation.update_attributes(job_id: 'some_id')

      subject.call

      expect(computation.job_id).to be_nil
    end
  end
end
