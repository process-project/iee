require 'rails_helper'

RSpec.describe Patient do
  subject { build(:patient) }

  it { should validate_presence_of(:case_number) }
  it { should validate_uniqueness_of(:case_number) }
  it { should validate_presence_of(:procedure_status) }

  it 'is setup with proper defaults' do
    expect(subject.procedure_status).to eq 'not_started'
    expect(subject.not_started?).to be_truthy
  end

  describe '#procedue_status' do
    it 'has localization label for each state' do
      Patient.procedure_statuses.each do |name,_|
        expect(I18n.t("patient.procedure_status.#{name}", default: 'N/A')).
          not_to eq 'N/A'
      end
    end
  end
end
