# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Computation, type: :model do
  subject { create(:computation) }

  it { should belong_to(:user) }
  it { should belong_to(:pipeline) }

  it do
    should validate_inclusion_of(:status).
      in_array(%w[new queued running error finished aborted])
  end

  it do
    should validate_inclusion_of(:pipeline_step).
      in_array(Pipeline::FLOWS.values.flatten.uniq.map { |s| s::STEP_NAME })
  end

  describe '.active' do
    it 'returns only new, queued or running computations' do
      subject.update(status: 'new')
      expect(Computation.active).to eq [subject]
      subject.update(status: 'queued')
      expect(Computation.active).to eq [subject]
      subject.update(status: 'running')
      expect(Computation.active).to eq [subject]
      subject.update(status: 'finished')
      expect(Computation.active).to be_empty
    end
  end

  describe '.submitted' do
    it 'returns only queued and running computations' do
      create(:rimrock_computation, status: 'new')
      queued = create(:rimrock_computation, status: 'queued')
      running = create(:webdav_computation, status: 'running')
      expect(Computation.submitted.pluck(:id)).
        to contain_exactly(queued.id, running.id)
    end
  end

  describe '.submitted_rimrock' do
    it 'returns only queued and running rimrock-based computations' do
      create(:webdav_computation, status: 'running')
      create(:rimrock_computation, status: 'new')
      queued = create(:rimrock_computation, status: 'queued')
      running = create(:rimrock_computation, status: 'running')
      expect(Computation.submitted_rimrock.pluck(:id)).
        to contain_exactly(queued.id, running.id)
    end
  end

  describe '.submitted_webdav' do
    it 'returns only queued and running webdav-based computations' do
      create(:rimrock_computation, status: 'running')
      create(:webdav_computation, status: 'new')
      queued = create(:webdav_computation, status: 'queued')
      running = create(:webdav_computation, status: 'running')
      expect(Computation.submitted_webdav.pluck(:id)).
        to contain_exactly(queued.id, running.id)
    end
  end
end
