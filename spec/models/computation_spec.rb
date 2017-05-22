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
      in_array(Patient::PIPELINE.keys.map(&:to_s))
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

  describe '.active_rimrock' do
    it 'returns active computations' do
      create(:rimrock_computation)
      expect(Computation.active_rimrock.collect(&:status)).to eq ['new']
    end
    it 'returns RimrockComputation' do
      create(:rimrock_computation)
      expect(Computation.active_rimrock.collect(&:type)).to all(eq 'RimrockComputation')
    end
  end

  describe '.active_webdav' do
    it 'returns active computations' do
      create(:webdav_computation)
      expect(Computation.active_webdav.collect(&:status)).to eq ['new']
    end
    it 'returns WebdavComputation' do
      create(:webdav_computation)
      expect(Computation.active_webdav.collect(&:type)).to all(eq 'WebdavComputation')
    end
  end
end
