# frozen_string_literal: true

require 'rails_helper'

describe WebdavDataFileSynchronizer, files: true do
  let(:user) { build(:user) }
  let(:correct_user) { build(:user, :file_store_user) }
  let(:null_project) { create(:project, project_name: '0000') }
  let(:test_project) { create(:project, project_name: '1234') }

  it 'does nothing for wrong input' do
    expect_any_instance_of(WebdavDataFileSynchronizer).not_to receive(:call_file_storage)
    call(nil, nil)
    call(build(:project, project_name: nil), nil)
    allow(user).to receive(:token) {}
    call(null_project, user)
  end

  it 'reports problems in logger' do
    allow(user).to receive(:token) {}
    expect(Rails.logger).to receive(:warn).
      with(I18n.t('data_file_synchronizer.no_token', user: user.name)).
      and_call_original
    call(null_project, user)
  end

  it 'warns if project directory is not accessible' do
    expect(Rails.logger).to receive(:warn).
      with(I18n.t('data_file_synchronizer.request_failure',
                  user: user.name,
                  project: test_project.project_name,
                  code: 403)).
      and_call_original
    expect { call(test_project, user) }.not_to(change { DataFile.count })
  end

  it 'does nothing if project directory is absent' do
    expect(Rails.logger).not_to receive(:warn)
    expect { call(null_project, correct_user) }.not_to(change { DataFile.count })
  end

  context 'when project directory exists and is accessible' do
    it 'handles network errors gracefully' do
      allow(Rails.configuration).to receive(:constants) do
        { 'file_store' => {
          'web_dav_base_url' => 'http://total.rubbish',
          'web_dav_base_path' => 'projects'
        } }
      end

      expect(Rails.logger).to receive(:warn).with(/File Stor/).and_call_original
      expect { call(test_project, user) }.not_to(change { DataFile.count })
    end

    context 'and there are project inputs' do
      let(:test_advanced_project) { create(:project, project_name: '5678') }

      it 'calls file storage and creates new input-related data_files' do
        expect { call(test_project, correct_user) }.to change { DataFile.count }.by(2)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(DataFile.all.map(&:output_of_id).compact).to be_empty
      end

      it 'only creates input data_files not yet present' do
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           project: test_project)
        expect { call(test_project, correct_user) }.to change { DataFile.count }.by(1)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(DataFile.all.map(&:output_of_id).compact).to be_empty
      end

      it 'recognizes files with regexps' do
        expect { call(test_advanced_project, correct_user) }.to change { DataFile.count }.by(1)
        expect(DataFile.all.map(&:data_type)).to match_array ['blood_flow_result']
        expect(DataFile.all.map(&:name)).to match_array ['fluidFlow-1-00002.dat']
      end

      it 'destroys data_files which are no longer stored in File Storage' do
        create(:data_file, data_type: 'blood_flow_result', project: test_project)
        create(:data_file, data_type: 'blood_flow_model', project: test_project)
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           project: test_project)
        create(:data_file, name: 'fluidFlow.cas',
                           data_type: 'fluid_virtual_model',
                           project: test_project)
        expect(test_project.reload.after_blood_flow_simulation?).to be_truthy
        expect { call(test_project, correct_user) }.to change { DataFile.count }.by(-2)
        expect(DataFile.all.map(&:data_type)).
          to match_array %w[fluid_virtual_model ventricle_virtual_model]
        expect(test_project.reload.virtual_model_ready?).to be_truthy
      end
    end

    context 'for a given pipeline' do
      let(:test_project_with_pipeline) { create(:project, :with_pipeline) }
      let(:pipeline) { test_project_with_pipeline.pipelines.first }

      it 'calls file storage and creates new pipeline-related data_files' do
        expect { call(test_project_with_pipeline, correct_user) }.
          to change { DataFile.count }.by(2)
        expect(pipeline.inputs.first.data_type).to eq 'ventricle_virtual_model'
        expect(pipeline.outputs.first.data_type).to eq 'blood_flow_result'
      end

      it 'only creates pipeline data_files not yet present' do
        create(:data_file, name: 'structural_vent.dat',
                           data_type: 'ventricle_virtual_model',
                           project: test_project_with_pipeline,
                           input_of: pipeline)
        create(:data_file, name: 'fluidFlow-1-00002.dat',
                           data_type: 'blood_flow_result',
                           project: test_project_with_pipeline,
                           output_of: pipeline)

        expect { call(test_project_with_pipeline, correct_user) }.to change { DataFile.count }.by(0)
      end

      it 'destroys pipeline data_files which are no longer stored in File Storage' do
        create(:data_file, name: 'structural_vent1.dat',
                           data_type: 'ventricle_virtual_model',
                           project: test_project_with_pipeline,
                           input_of: pipeline)
        create(:data_file, name: 'structural_vent2.dat',
                           data_type: 'ventricle_virtual_model',
                           project: test_project_with_pipeline,
                           output_of: pipeline)

        call(test_project_with_pipeline, correct_user)

        expect(DataFile.count).to eq 2
        expect(pipeline.inputs.first.data_type).to eq 'ventricle_virtual_model'
        expect(pipeline.outputs.first.data_type).to eq 'blood_flow_result'
      end
    end
  end

  def call(project, user)
    WebdavDataFileSynchronizer.new(project, user).call
  end

  def file_handle(project_name, filename)
    Rails.configuration.constants['file_store']['web_dav_base_url'] +
      Rails.configuration.constants['file_store']['web_dav_base_path'] +
      "/#{Rails.env}/projects/#{project_name}/#{filename}"
  end
end
