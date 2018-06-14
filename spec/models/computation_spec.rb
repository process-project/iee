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

  # Disabled untill we will be able to deal with the steps, which are there
  # but right now not used in any pipeline
  # it do
  #   should validate_inclusion_of(:pipeline_step).
  #     in_array(Pipeline::FLOWS.values.flatten.uniq.map { |s| s::STEP_NAME })
  # end

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
      create(:scripted_computation, status: 'new')
      queued = create(:scripted_computation, status: 'queued')
      running = create(:webdav_computation, status: 'running')
      expect(Computation.submitted.pluck(:id)).
        to contain_exactly(queued.id, running.id)
    end
  end

  describe '.submitted_scripted' do
    it 'returns only queued and running scripted computations' do
      create(:webdav_computation, status: 'running')
      create(:scripted_computation, status: 'new')
      queued_r = create(:scripted_computation, status: 'queued', deployment: 'cluster')
      running_r = create(:scripted_computation, status: 'running', deployment: 'cluster')
      queued_c = create(:scripted_computation, status: 'queued', deployment: 'cloud')
      running_c = create(:scripted_computation, status: 'running', deployment: 'cloud')
      expect(Computation.submitted_rimrock.pluck(:id)).
        to contain_exactly(queued_r.id, running_r.id)
      expect(Computation.submitted_cloud.pluck(:id)).
        to contain_exactly(queued_c.id, running_c.id)
    end
  end

  describe '.submitted_webdav' do
    it 'returns only queued and running webdav-based computations' do
      create(:scripted_computation, status: 'running')
      create(:webdav_computation, status: 'new')
      queued = create(:webdav_computation, status: 'queued')
      running = create(:webdav_computation, status: 'running')
      expect(Computation.submitted_webdav.pluck(:id)).
        to contain_exactly(queued.id, running.id)
    end
  end
end
