# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Patient do
  subject { build(:patient) }

  it { should validate_presence_of(:case_number) }
  it { should validate_uniqueness_of(:case_number) }
  it { should allow_value('pn4-_.').for(:case_number) }
  it { should_not allow_value("'{}&%$@#").for(:case_number) }

  describe '#status' do
    it 'returns last pipeline status' do
      patient = create(:patient)
      p1 = create(:pipeline, patient: patient)
      create(:computation, status: :error, pipeline: p1)
      p2 = create(:pipeline, patient: patient)
      create(:computation, status: :finished, pipeline: p2)

      expect(patient.status).to eq :success
    end
  end
end
