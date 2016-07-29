# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DataFile do
  subject { build(:data_file) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:data_type) }
  it { should validate_presence_of(:patient) }

  context 'when related to a patient' do
    it 'touches related patient on modification' do
      expect(subject.patient)
        .to receive(:update_procedure_status).and_call_original
      subject.name = 'something_new'
      subject.save
    end

    it 'touches related patient on creation' do
      patient = create(:patient)
      expect(patient)
        .to receive(:update_procedure_status).and_call_original
      create(:data_file, patient: patient)
    end

    it 'touches related patient on destruction' do
      expect(subject.patient)
        .to receive(:update_procedure_status).and_call_original
      subject.destroy
    end
  end
end
