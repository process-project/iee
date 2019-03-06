# frozen_string_literal: true

require 'rails_helper'

describe DataFiles::Destroy do
  it 'destroys deleted file' do
    df = create(:data_file)

    expect { described_class.new([File.join('/', df.path)]).call }.
      to change { DataFile.count }.by(-1)

    expect(DataFile.exists?(df.id)).to be_falsy
  end

  it 'destroys all files in directory and subdirectories' do
    patient = create(:patient)
    pipeline = create(:pipeline, patient: patient)
    _input = create(:data_file, patient: patient)
    _pipeline_input = create(:data_file, patient: patient, input_of: pipeline)
    _pipeline_output = create(:data_file, patient: patient, output_of: pipeline)

    expect { described_class.new([File.join('/', patient.working_dir)]).call }.
      to change { DataFile.count }.by(-3)
  end
end
