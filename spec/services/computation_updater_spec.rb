# frozen_string_literal: true

require 'rails_helper'

describe ComputationUpdater do
  let(:project) { create(:project) }
  let(:pipeline) { create(:pipeline, project: project) }
  let!(:c1) { create(:rimrock_computation, pipeline: pipeline, status: 'new') }
  let!(:c2) { create(:singularity_computation, pipeline: pipeline, status: 'finished') }

  it 'broadcast computation change' do
    expect(ComputationChannel).
      to receive(:broadcast_to).
      with(c1, hash_including(reload_step: true, reload_files: false))

    expect(ComputationChannel).
      to receive(:broadcast_to).
      with(c2, hash_including(reload_step: false, reload_files: false))

    described_class.new(c1).call
  end

  it 'broadcast output reload after finish' do
    expect(ComputationChannel).
      to receive(:broadcast_to).
      with(c1, hash_including(reload_step: false, reload_files: true))

    expect(ComputationChannel).
      to receive(:broadcast_to).
      with(c2, hash_including(reload_step: true, reload_files: true))

    described_class.new(c2).call
  end

  it 'broadcast reload project pipelines statuses' do
    expect(ProjectChannel).
      to receive(:broadcast_to).
      with(project, anything)

    described_class.new(c2).call
  end
end
