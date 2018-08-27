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

    context 'and required inputs' do
      before do
        create(:data_file,
               project: pipeline.project,
               data_type: :parameter_optimization_result)
      end
      it 'starts created runnable pipeline step' do
        create(:rimrock_computation,
               status: 'created', pipeline_step: '0d_models',
               pipeline: pipeline)
        runner = instance_double(PipelineSteps::Rimrock::Runner)

        allow(PipelineSteps::Rimrock::Runner).to receive(:new).and_return(runner)
        expect(runner).to receive(:call)

        described_class.new(pipeline).call
      end

      it 'does not start already started pipeline step' do
        create(:rimrock_computation,
               status: 'running', pipeline_step: '0d_models',
               pipeline: pipeline)

        expect(PipelineSteps::Rimrock::Runner).to_not receive(:new)

        described_class.new(pipeline).call
      end
    end

    context 'and without required input' do
      it 'does not start not runnable pipeline step' do
        create(:rimrock_computation,
               status: 'created', pipeline_step: '0d_models',
               pipeline: pipeline)

        runner = double(runnable?: false)

        allow(PipelineSteps::Rimrock::Runner).to receive(:new).and_return(runner)
        expect(runner).to_not receive(:run)

        described_class.new(pipeline).call
      end
    end
  end

  context 'with invalid user proxy' do
    before { allow(proxy).to receive(:valid?).and_return(false) }

    it 'runnable rimrock computations are not started' do
      create(:rimrock_computation,
             status: 'created', pipeline_step: '0d_models',
             pipeline: pipeline)
      create(:data_file,
             project: pipeline.project,
             data_type: :parameter_optimization_result)

      runner = double(runnable?: true)

      allow(PipelineSteps::Rimrock::Runner).to receive(:new).and_return(runner)
      expect(runner).to_not receive(:call)

      described_class.new(pipeline).call
    end
  end
end
