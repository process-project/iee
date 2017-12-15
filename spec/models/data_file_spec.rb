# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataFile do
  subject { build(:data_file) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:data_type) }
  it { should validate_presence_of(:patient) }

  context 'when related to a patient' do
    it 'touches related patient on modification' do
      expect(subject.patient).
        to receive(:update_procedure_status).and_call_original
      subject.name = 'something_new'
      subject.save
    end

    it 'touches related patient on creation' do
      patient = create(:patient)
      expect(patient).
        to receive(:update_procedure_status).and_call_original
      create(:data_file, patient: patient)
    end

    it 'touches related patient on destruction' do
      expect(subject.patient).
        to receive(:update_procedure_status).and_call_original
      subject.destroy
    end
  end

  context '#path' do
    it 'returns relative path for patient input' do
      input = build(:data_file,
                    patient: build(:patient, case_number: '123'), name: 'foo')

      expect(input.path).to eq 'test/patients/123/inputs/foo'
    end

    it 'returns relative path for patient pipeline output' do
      patient = build(:patient, case_number: '123')
      pipeline = build(:pipeline, iid: '1', patient: patient)
      input = build(:data_file, patient: patient, output_of: pipeline, name: 'foo')

      expect(input.path).to eq 'test/patients/123/pipelines/1/outputs/foo'
    end

    it 'returns relative path for patient pipeline input' do
      patient = build(:patient, case_number: '123')
      pipeline = build(:pipeline, iid: '1', patient: patient)
      input = build(:data_file, patient: patient, input_of: pipeline, name: 'foo')

      expect(input.path).to eq 'test/patients/123/pipelines/1/inputs/foo'
    end
  end

  describe '#content', files: true do
    let(:correct_user) { build(:user, :file_store_user) }
    let(:test_patient_with_pipeline) do
      create(:patient, :with_pipeline).tap { |p| p.execute_data_sync(correct_user) }
    end
    let(:test_patient_with_input) do
      create(:patient, case_number: '5678').tap { |p| p.execute_data_sync(correct_user) }
    end

    it 'downloads pipeline file content as a string' do
      expect(test_patient_with_pipeline.data_files.first.content(correct_user)).to eq "fake\n"
    end

    it 'downloads patient input file content as a string' do
      expect(test_patient_with_input.data_files.first.content(correct_user)).to eq "fake\n"
    end
  end

  describe '.data_type' do
    it 'has all values localised' do
      locales = DataFile.data_types.keys.map { |dt| I18n.t "data_file.data_types.#{dt}" }
      expect(locales.any? { |l| l.include? 'translation missing' }).to be_falsey
    end
  end
end
