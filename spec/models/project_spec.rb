# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project do
  subject { build(:project) }

  it { should validate_presence_of(:project_name) }
  it { should validate_uniqueness_of(:project_name) }
  it { should validate_presence_of(:procedure_status) }
  it { should allow_value('pn4-_.').for(:project_name) }
  it { should_not allow_value("'{}&%$@#").for(:project_name) }

  it 'is setup with proper defaults' do
    expect(subject.procedure_status).to eq 'not_started'
    expect(subject.not_started?).to be_truthy
  end

  describe '#procedue_status' do
    it 'has localization label for each state' do
      Project.procedure_statuses.each_key do |name|
        expect(I18n.t("project.procedure_status.#{name}", default: 'N/A')).
          not_to eq 'N/A'
      end
    end

    it 'gets updated when appropriate data_files appear' do
      expect(subject.not_started?).to be_truthy
      create(:data_file, data_type: 'image', project: subject)
      expect(subject.reload.imaging_uploaded?).to be_truthy
      create(:data_file, data_type: 'segmentation_result', project: subject)
      expect(subject.reload.segmentation_ready?).to be_truthy
      create(:data_file, data_type: 'ventricle_virtual_model', project: subject.reload)
      create(:data_file, data_type: 'fluid_virtual_model', project: subject.reload)
      expect(subject.reload.virtual_model_ready?).to be_truthy
      create(:data_file, data_type: 'blood_flow_result', project: subject)
      create(:data_file, data_type: 'blood_flow_model', project: subject)
      expect(subject.reload.after_blood_flow_simulation?).to be_truthy
    end

    it 'gets downgraded when an important data_file disappears' do
      data_file = create(:data_file, data_type: 'ventricle_virtual_model', project: subject)
      create(:data_file, data_type: 'fluid_virtual_model', project: subject.reload)
      expect(subject.reload.virtual_model_ready?).to be_truthy
      data_file.destroy
      expect(subject.not_started?).to be_truthy
    end
  end

  describe '#status' do
    it 'returns last pipeline status' do
      project = create(:project)
      p1 = create(:pipeline, project: project)
      create(:computation, status: :error, pipeline: p1)
      p2 = create(:pipeline, project: project)
      create(:computation, status: :finished, pipeline: p2)

      expect(project.status).to eq :success
    end
  end
end
