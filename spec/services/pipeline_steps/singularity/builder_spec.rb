# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelineSteps::Singularity::Builder do
  let(:pipeline) { create(:pipeline) }

  let(:parameters) do
    [
      StepParameter.new(label: 'label1',
                        name: '',
                        description: '',
                        rank: 0,
                        datatype: 'string',
                        default: ''),
      StepParameter.new(label: 'label2',
                        name: '',
                        description: '',
                        rank: 0,
                        datatype: 'integer',
                        default: 1),
      StepParameter.new(label: 'label3',
                        name: '',
                        description: '',
                        rank: 0,
                        datatype: 'multi',
                        default: 'first',
                        values: %w[first second])
    ]
  end

  let(:proper_parameter_values) do
    ActionController::Parameters.new(
      container_name: 'test_name',
      container_tag: 'test_tag',
      compute_site_name: ComputeSite.where(name: :krk).first.full_name,
      label1: 'test_label1',
      label2: 'test_label2',
      label3: 'test_label3'
    )
  end

  let(:wrong_parameter_values) do
    ActionController::Parameters.new(
      asd: 'asd'
    )
  end

  let(:unsafe_parameter_values) do
    proper_parameter_values.merge(unsafe_label: 'unsafe')
  end

  it 'creates singularity computation' do
    computation = described_class.new(
      pipeline,
      'singularity_step',
      proper_parameter_values,
      parameters
    ).call

    expect(computation).to be_instance_of SingularityComputation
    expect(computation).to be_persisted
    expect(computation.pipeline_step).to eq 'singularity_step'
    expect(computation.pipeline).to eq pipeline
    expect(computation.container_name).to eq 'test_name'
    expect(computation.container_tag).to eq 'test_tag'
    expect(computation.compute_site.name).to eq :krk
    expect(computation.user).to eq pipeline.user

    expect(computation.parameter_values.symbolize_keys).to include(:label1, :label2, :label3)
  end

  context 'given wrong no of parameters' do
    it 'raises ActionController::ParameterMissing' do
      expect do
        described_class.new(
          pipeline,
          'singularity_step',
          wrong_parameter_values,
          parameters
        )
      end.to raise_error(ActionController::ParameterMissing)
    end
  end

  context 'given unsafe parameter' do
    it "doesn't create computation with unsafe parameter" do
      computation = described_class.new(
        pipeline,
        'singularity_step',
        proper_parameter_values,
        parameters
      ).call

      expect(computation.parameter_values).not_to include(:unsafe_label)
    end
  end
end
