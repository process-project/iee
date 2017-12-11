# frozen_string_literal: true

require 'rails_helper'

describe Patients::PatientSynchronizer do
  let(:user) { build(:user, email: Rails.configuration.constants['data_sets']['sync_user_email']) }
  let(:patient) { build(:patient, case_number: 'cs') }
  let(:patient_x) { build(:patient, case_number: 'patient_x') }

  it 'ignores existing patients' do
    file_store.delete(patient_x.working_dir)
    expect(file_store.exists?(patient_x.working_dir)).to be_falsey

    Patients::Create.new(user, patient_x).call
    expect(file_store.exists?(patient_x.inputs_dir)).to be_truthy

    patient_synchronizer = described_class.new
    expect(patient_synchronizer).to receive(:query_ready_patients).and_return [%w[patient_x CT]]

    patient_synchronizer.call
    expect(
      file_store.exists?("#{patient_x.inputs_dir}/imaging_patient_x_CT_init.zip")
    ).to be_falsey
  end

  it 'removes duplicated DataSets entries' do
    patient_synchronizer = described_class.new

    expect_any_instance_of(DataSets::Client).
      to receive(:call).
      and_return [['header'], %w[patient_x CT], %w[patient_x MRI], %w[patient_x CT]]
    allow(patient_synchronizer).
      to receive(:user).
      and_return(user)
    expect(patient_synchronizer).
      to receive(:create_new_patient).
      with('patient_x', %w[CT MRI])

    patient_synchronizer.call
  end

  def file_store
    Webdav::FileStore.new(user)
  end
end
