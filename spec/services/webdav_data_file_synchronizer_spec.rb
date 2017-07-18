# frozen_string_literal: true

require 'rails_helper'

describe WebdavDataFileSynchronizer, files: true do
  let(:user) { build(:user) }
  let(:correct_user) { build(:user, :file_store_user) }
  let(:null_patient) { create(:patient, case_number: '0000') }
  let(:test_patient) { create(:patient, case_number: '1234') }

  it 'does nothing for wrong input' do
    expect_any_instance_of(WebdavDataFileSynchronizer).not_to receive(:call_file_storage)
    call(nil, nil)
    call(build(:patient, case_number: nil), nil)
    allow(user).to receive(:token) {}
    call(null_patient, user)
  end

  it 'reports problems in logger' do
    allow(user).to receive(:token) {}
    expect(Rails.logger).to receive(:warn).
      with(I18n.t('data_file_synchronizer.no_token', user: user.name)).
      and_call_original
    call(null_patient, user)
  end

  it 'warns if patient directory is not accessible' do
    expect(Rails.logger).to receive(:warn).
      with(I18n.t('data_file_synchronizer.request_failure',
                  user: user.name,
                  patient: test_patient.case_number,
                  code: 403)).
      and_call_original
    expect { call(test_patient, user) }.not_to(change { DataFile.count })
  end

  it 'does nothing if patient directory is absent' do
    expect(Rails.logger).not_to receive(:warn)
    expect { call(null_patient, correct_user) }.not_to(change { DataFile.count })
  end

  context 'when patient directory exists and is accessible' do
    it 'handles network errors gracefully' do
      expect(Rails.logger).to receive(:warn).
        with(I18n.t('data_file_synchronizer.no_fs_client')).
        and_call_original
      allow(Rails.configuration).to receive(:constants) do
        { 'file_store' => {
          'web_dav_base_url' => 'http://total.rubbish',
          'web_dav_base_path' => 'patients'
        } }
      end
      expect { call(test_patient, user) }.not_to(change { DataFile.count })
    end

    context 'and there are patient inputs' do
      let(:test_advanced_patient) { create(:patient, case_number: '5678') }

      it 'calls file storage and creates new input-related data_files' do
        expect { call(test_patient, correct_user) }.to change { DataFile.count }.by(2)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(DataFile.all.map(&:pipeline_id).compact).to be_empty
      end

      it 'only creates input data_files not yet present' do
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           patient: test_patient)
        expect { call(test_patient, correct_user) }.to change { DataFile.count }.by(1)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(DataFile.all.map(&:pipeline_id).compact).to be_empty
      end

      it 'recognizes files with regexps' do
        expect { call(test_advanced_patient, correct_user) }.to change { DataFile.count }.by(1)
        expect(DataFile.all.map(&:data_type)).to match_array ['blood_flow_result']
        expect(DataFile.all.map(&:name)).to match_array ['fluidFlow-1-00002.dat']
      end

      it 'destroys data_files which are no longer stored in File Storage' do
        create(:data_file, data_type: 'blood_flow_result', patient: test_patient)
        create(:data_file, data_type: 'blood_flow_model', patient: test_patient)
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           patient: test_patient)
        create(:data_file, name: 'fluidFlow.cas',
                           data_type: 'fluid_virtual_model',
                           patient: test_patient)
        expect(test_patient.reload.after_blood_flow_simulation?).to be_truthy
        expect { call(test_patient, correct_user) }.to change { DataFile.count }.by(-2)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(test_patient.reload.virtual_model_ready?).to be_truthy
      end
    end

    context 'for a given pipeline' do
      let(:test_patient_with_pipeline) { create(:patient, :with_pipeline) }

      it 'calls file storage and creates new pipeline-related data_files' do
        expect { call(test_patient_with_pipeline, correct_user) }.
          to change { DataFile.count }.by(1)
        expect(DataFile.first.data_type).to eq 'blood_flow_result'
        expect(DataFile.first.pipeline).to eq test_patient_with_pipeline.pipelines.first
      end

      it 'only creates pipeline data_files not yet present' do
        create(:data_file, name: 'fluidFlow-1-00002.dat',
                           data_type: 'blood_flow_result',
                           patient: test_patient_with_pipeline,
                           pipeline: test_patient_with_pipeline.pipelines.first)
        expect { call(test_patient_with_pipeline, correct_user) }.to change { DataFile.count }.by(0)
      end

      it 'destroys pipeline data_files which are no longer stored in File Storage' do
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           patient: test_patient_with_pipeline,
                           pipeline: test_patient_with_pipeline.pipelines.first)
        call(test_patient_with_pipeline, correct_user)
        expect(DataFile.count).to eq 1
        expect(DataFile.first.data_type).to eq 'blood_flow_result'
        expect(DataFile.first.pipeline).to eq test_patient_with_pipeline.pipelines.first
      end
    end
  end

  def call(patient, user)
    WebdavDataFileSynchronizer.new(patient, user).call
  end

  def file_handle(case_number, filename)
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_base_path'] +
      "/#{Rails.env}/patients/#{case_number}/#{filename}"
  end
end
