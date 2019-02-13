# frozen_string_literal: true

require 'rails_helper'

describe Pipelines::Affected do
  let(:patient) { create(:patient) }

  it 'returns all pipelines for patient input' do
    all_pipelines = create_list(:pipeline, 2, patient: patient)
    data_file = create(:data_file, patient: patient)

    expect(described_class.new([data_file]).call).
      to contain_exactly(*all_pipelines)
  end

  it 'returns input pipeline' do
    pipeline, = create_list(:pipeline, 2, patient: patient)
    data_file = create(:data_file, patient: patient, input_of: pipeline)

    expect(described_class.new([data_file]).call).
      to contain_exactly(pipeline)
  end

  it 'returns input pipeline' do
    pipeline, = create_list(:pipeline, 2, patient: patient)
    data_file = create(:data_file, patient: patient, output_of: pipeline)

    expect(described_class.new([data_file]).call).
      to contain_exactly(pipeline)
  end

  it 'does not duplicate records' do
    p1, p2 = create_list(:pipeline, 2, patient: patient)

    patient_input = create(:data_file, patient: patient)
    p1_input = create(:data_file, patient: patient, input_of: p1)
    p2_output = create(:data_file, patient: patient, output_of: p2)

    expect(described_class.new([patient_input, p1_input, p2_output]).call.size).
      to eq(2)
  end
end
