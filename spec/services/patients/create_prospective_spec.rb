# frozen_string_literal: true

require 'rails_helper'

describe Patients::CreateProspective, files: true do
  let(:user) { build(:user, email: Rails.configuration.constants['data_sets']['sync_user_email']) }
  let(:patient) { build(:patient, case_number: 'cs') }
  let(:patient_x) { build(:patient, case_number: 'patient_x') }

  it 'checks modality existence in FileStore' do
    webdav = instance_double(Webdav::Client)
    allow(webdav).to receive(:r_mkdir)
    expect(webdav).
      to receive(:exists?).with('test/ProspectiveImagingTest/cs/Initial_MRI/file.zip').
      and_return(false)

    expect { described_class.new(user, patient, %w[MRI], client: webdav).call }.
      to raise_error StandardError, 'None of modalities (["MRI"]) exist for patient (cs)'
  end

  it 'creates a patient if at least one modality exists' do
    file_store.delete(patient_x.working_dir)
    expect(file_store.exists?(patient_x.working_dir)).to be_falsey

    create_prospective = described_class.new(user, patient_x, %w[MRI CT])
    allow(create_prospective).to receive(:move_imaging_file).with('CT')

    expect { create_prospective.call }.
      to change { Patient.count }.by(1)
  end

  it 'copies found modality to patient input dir' do
    file_store.delete(patient_x.working_dir)
    expect(file_store.exists?(patient_x.working_dir)).to be_falsey

    described_class.new(user, patient_x, %w[MRI CT]).call
    expect(
      file_store.exists?("#{patient_x.inputs_dir}/imaging_patient_x_CT_init.zip")
    ).to be_truthy
    expect(patient_x.data_files.count).to eq 1
    expect(patient_x.data_files[0].data_type).to eq 'image'
  end

  it 'respects existing patient file structure' do
    file_store.r_mkdir(patient_x.inputs_dir)
    Webdav::UploadFile.
      new(file_store, 'spec/support/data_files/foo.zip', "#{patient_x.inputs_dir}/foo.zip").
      call
    expect(
      file_store.exists?("#{patient_x.inputs_dir}/foo.zip")
    ).to be_truthy

    described_class.new(user, patient_x, %w[MRI CT]).call
    expect(
      file_store.exists?("#{patient_x.inputs_dir}/foo.zip")
    ).to be_truthy
  end

  it 'rollbacks patient creation when modality move fails' do
    create_prospective = described_class.new(user, patient_x, %w[MRI CT])
    allow(create_prospective).to receive(:move_imaging_file).with('CT').and_raise('!')

    expect { create_prospective.call }.to raise_error('!')
    expect(patient.persisted?).to be_falsey
    expect(Patient.count).to eq 0
  end

  def file_store
    Webdav::FileStore.new(user)
  end
end
