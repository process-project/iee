# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PatientsHelper do
  describe '#procedure_progress' do
    let(:patient) { build(:patient) }

    it 'shows 0 progress for strange status values' do
      allow(patient).to receive(:procedure_status).and_return('wrong')
      expect(procedure_progress(patient)).to eq '0.0%'
    end

    it 'shows first (default) status as 0 progress' do
      expect(procedure_progress(patient)).to eq '0.0%'
    end

    it 'cant get higher than 100 percent' do
      max_status = Patient.procedure_statuses.max_by(&:second)[0]
      patient.procedure_status = max_status
      expect(procedure_progress(patient)).to eq '100.0%'
    end
  end
end
