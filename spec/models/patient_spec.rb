# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Patient do
  subject { build(:patient) }

  it { should validate_presence_of(:case_number) }
  it { should validate_uniqueness_of(:case_number) }
  it { should validate_presence_of(:procedure_status) }
  it { should allow_value('pn4-~_.').for(:case_number) }
  it { should_not allow_value("'{}&%$@#").for(:case_number) }

  it 'is setup with proper defaults' do
    expect(subject.procedure_status).to eq 'not_started'
    expect(subject.not_started?).to be_truthy
  end

  describe '#procedue_status' do
    it 'has localization label for each state' do
      Patient.procedure_statuses.each do |name, _|
        expect(I18n.t("patient.procedure_status.#{name}", default: 'N/A')).
          not_to eq 'N/A'
      end
    end

    it 'gets updated when appropriate data_files appear' do
      expect(subject.not_started?).to be_truthy
      create(:data_file, data_type: 'image', patient: subject)
      expect(subject.reload.imaging_uploaded?).to be_truthy
      create(:data_file, data_type: 'segmentation_result', patient: subject)
      expect(subject.reload.segmentation_ready?).to be_truthy
      create(:data_file, data_type: 'ventricle_virtual_model', patient: subject.reload)
      create(:data_file, data_type: 'fluid_virtual_model', patient: subject.reload)
      expect(subject.reload.virtual_model_ready?).to be_truthy
      create(:data_file, data_type: 'blood_flow_result', patient: subject)
      create(:data_file, data_type: 'blood_flow_model', patient: subject)
      expect(subject.reload.after_blood_flow_simulation?).to be_truthy
    end

    it 'gets downgraded when an important data_file disappears' do
      data_file = create(:data_file, data_type: 'ventricle_virtual_model', patient: subject)
      create(:data_file, data_type: 'fluid_virtual_model', patient: subject.reload)
      expect(subject.reload.virtual_model_ready?).to be_truthy
      data_file.destroy
      expect(subject.not_started?).to be_truthy
    end
  end
end
