# frozen_string_literal: true

require 'rails_helper'

describe DataFiles::Create do
  it 'creates patient input data files' do
    patient = create(:patient)

    expect do
      described_class.
        new([File.join('/', patient.working_dir, 'inputs', 'file.zip')]).call
    end.to change { DataFile.count }.by(1)

    data_file = DataFile.last

    expect(data_file.data_type).to eq('image')
    expect(data_file.patient).to eq(patient)
    expect(data_file.input_of).to be_nil
    expect(data_file.output_of).to be_nil
  end

  it 'does not create input data file when type is not found' do
    patient = create(:patient)

    expect do
      described_class.
        new([File.join('/', patient.working_dir, 'inputs', 'file.unknown')]).call
    end.to_not(change { DataFile.count })
  end

  it 'does not create duplicates' do
    patient = create(:patient)
    DataFile.create(name: 'file.zip', data_type: 'image', patient: patient)

    expect do
      described_class.
        new([File.join('/', patient.working_dir, 'inputs', 'file.zip')]).call
    end.to_not(change { DataFile.count })
  end

  it 'creates pipeline input file' do
    patient = create(:patient)
    pipeline = create(:pipeline, patient: patient)

    expect do
      described_class.
        new([File.join('/', pipeline.inputs_dir, 'inputs', 'file.zip')]).call
    end.to change { DataFile.count }.by(1)

    data_file = DataFile.last

    expect(data_file.data_type).to eq('image')
    expect(data_file.patient).to eq(patient)
    expect(data_file.input_of).to eq(pipeline)
    expect(data_file.output_of).to be_nil
  end

  it 'creates pipeline output file' do
    patient = create(:patient)
    pipeline = create(:pipeline, patient: patient)

    expect do
      described_class.
        new([File.join('/', pipeline.outputs_dir, 'inputs', 'file.zip')]).call
    end.to change { DataFile.count }.by(1)

    data_file = DataFile.last

    expect(data_file.data_type).to eq('image')
    expect(data_file.patient).to eq(patient)
    expect(data_file.input_of).to be_nil
    expect(data_file.output_of).to eq(pipeline)
  end

  it 'ignores files from outsite patients folder' do
    expect { described_class.new(['/a/file.zip', '/a/b/file.zip']).call }.
      to_not(change { DataFile.count })
  end

  it 'ignores files from other patient directory' do
    patient = create(:patient)

    expect do
      described_class.new([File.join('/', patient.working_dir, 'a', 'file.zip')]).call
    end.to_not(change { DataFile.count })
  end
end