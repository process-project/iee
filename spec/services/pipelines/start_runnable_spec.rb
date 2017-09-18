# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::StartRunnable do
  let(:pipeline) { create(:pipeline, mode: :automatic) }
  let(:proxy) do
    instance_double(Proxy).tap do |proxy|
      allow(Proxy).to receive(:new).and_return(proxy)
    end
  end

  context 'with valid user proxy' do
    before { allow(proxy).to receive(:valid?).and_return(true) }

    it 'starts created runnable pipeline step' do
      create(:rimrock_computation,
             status: 'created', pipeline_step: 'blood_flow_simulation',
             pipeline: pipeline)

      runner = double(runnable?: true)

      allow(PipelineStep::BloodFlowSimulation).to receive(:new).and_return(runner)
      expect(runner).to receive(:run)

      described_class.new(pipeline).call
    end

    it 'does not start already started pipeline step' do
      create(:rimrock_computation,
             status: 'running', pipeline_step: 'blood_flow_simulation',
             pipeline: pipeline)

      expect(PipelineStep::BloodFlowSimulation).to_not receive(:new)

      described_class.new(pipeline).call
    end

    it 'does not start not runnable pipeline step' do
      create(:rimrock_computation,
             status: 'created', pipeline_step: 'blood_flow_simulation',
             pipeline: pipeline)

      runner = double(runnable?: false)

      allow(PipelineStep::BloodFlowSimulation).to receive(:new).and_return(runner)
      expect(runner).to_not receive(:run)

      described_class.new(pipeline).call
    end
  end

  context 'with invalid user proxy' do
    before { allow(proxy).to receive(:valid?).and_return(false) }

    it 'runnable rimrock computations are not started' do
      create(:rimrock_computation,
             status: 'created', pipeline_step: 'blood_flow_simulation',
             pipeline: pipeline)

      runner = double(runnable?: true)

      allow(PipelineStep::BloodFlowSimulation).to receive(:new).and_return(runner)
      expect(runner).to_not receive(:run)

      described_class.new(pipeline).call
    end
  end
end
