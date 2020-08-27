# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Rimrock::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }

  let(:computation) { create(:rimrock_computation, pipeline_step: 'placeholder_step') }

  context 'inputs are available' do

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
      computation.update_attributes(job_id: 'some_id', revision: 'master')

      subject.call

      expect(computation.job_id).to be_nil
    end
  end
end
