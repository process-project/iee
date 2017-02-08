# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Computation, type: :model do
  subject { create(:computation) }

  it { should validate_presence_of(:script) }
  it { should validate_presence_of(:user) }
  it do
    should validate_inclusion_of(:status).
      in_array(%w(new queued running error finished aborted))
  end

  it { should belong_to(:user) }

  describe '.active' do
    it 'returns only new, queued or running computations' do
      expect(Computation.active).to eq [subject]
      subject.update(status: 'queued')
      expect(Computation.active).to eq [subject]
      subject.update(status: 'running')
      expect(Computation.active).to eq [subject]
      subject.update(status: 'finished')
      expect(Computation.active).to be_empty
    end
  end

  describe '.type_for_patient_status' do
    it 'properly maps patient procedure status to required computation' do
      expect(Computation.type_for_patient_status('virtual_model_ready')).
        to eq 'blood_flow_simulation'
      expect(Computation.type_for_patient_status('after_parameter_estimation')).
        to eq 'heart_model_computation'
    end
  end
end
