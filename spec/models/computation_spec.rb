# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Computation, type: :model do
  subject { create(:computation) }

  it { should validate_presence_of(:user) }
  it do
    should validate_inclusion_of(:status).
      in_array(%w(new queued running error finished aborted))
  end

  it do
    should validate_inclusion_of(:pipeline_step).
      in_array(Patient::PIPELINE.keys.map{ |k| k.to_s })
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
end
