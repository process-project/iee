# frozen_string_literal: true

require 'rails_helper'
require 'models/pipeline/rimrock_based_step_shared_examples'
require 'models/pipeline/step_shared_examples'

RSpec.describe PipelineStep::BloodFlowSimulation do
  let(:user) { create(:user) }
  let(:pipeline) { create(:pipeline, user: user, flow: 'not_used_steps') }
  let(:computation) { described_class::DEF.builder_for(pipeline, {}).call }

  before do
    allow(Rimrock::StartJob).to receive(:perform_later)
  end

  context 'inputs are available' do
    before do
      create(:data_file, data_type: :fluid_virtual_model, patient: pipeline.patient)
      create(:data_file, data_type: :ventricle_virtual_model, patient: pipeline.patient)
    end

    it_behaves_like 'ready to run step'
    it_behaves_like 'a Rimrock-based ready to run step'

    let(:template_fetcher) do
      fetcher = class_double(Gitlab::GetFile)
      allow(fetcher).to receive(:new).
        with('eurvalve/blood-flow', 'blood_flow.sh.erb', anything).
        and_return(double(call: 'script payload'))

      fetcher
    end

    let(:revision_fetcher) do
      fetcher = class_double(Gitlab::Revision)
      allow(fetcher).to receive(:new).
        with('eurvalve/blood-flow', anything).
        and_return(double(call: 'rev'))

      fetcher
    end

    it 'creates computation with script returned by generator' do
      service = described_class.new(computation,
                                    template_fetcher: template_fetcher,
                                    revision_fetcher: revision_fetcher)
      computation.assign_attributes(revision: 'revision')

      service.run

      expect(computation.script).to include 'script payload'
    end

    it 'set job_id to null while restarting computation' do
      service = described_class.new(computation,
                                    template_fetcher: template_fetcher,
                                    revision_fetcher: revision_fetcher)
      computation.update_attributes(job_id: 'some_id', revision: 'master')

      service.run

      expect(computation.job_id).to be_nil
    end
  end

  context 'inputs are not available' do
    it_behaves_like 'not ready to run step'
  end
end
