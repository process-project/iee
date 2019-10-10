# frozen_string_literal: true

require 'rails_helper'
require 'services/pipeline_steps/runner_shared_examples'

RSpec.describe PipelineSteps::Cloudify::Runner do
  let(:updater) { instance_double(ComputationUpdater, call: true) }
  let(:deployer) { instance_double(Cloudify::CreateDeployment) }

  let(:computation) { create(:cloudify_computation, pipeline_step: 'cloudify_step') }

  subject do
    described_class.new(computation,
                        updater: double(new: updater))
  end

  before(:each) do
    allow_any_instance_of(Cloudify::CreateDeployment).to receive(:call)
  end

  it 'starts a Cloudify deployment' do
    expect(Cloudify::StartJob).to receive(:perform_later)

    subject.call
  end
end
