# frozen_string_literal: true

require 'rails_helper'

describe ComputationUpdater do
  let(:pipeline) { create(:pipeline) }
  let!(:c1) { create(:rimrock_computation, pipeline: pipeline, status: 'new') }
  let!(:c2) { create(:webdav_computation, pipeline: pipeline, status: 'finished') }

  it 'broadcast computation change' do
    expect(PipelineChannel).
      to receive(:broadcast_to).
      with(c1, hash_including(reload_step: true, reload_files: false))

    expect(PipelineChannel).
      to receive(:broadcast_to).
      with(c2, hash_including(reload_step: false, reload_files: false))

    described_class.new(computation: c1).call
  end

  it 'broadcast output reload after finish' do
    expect(PipelineChannel).
      to receive(:broadcast_to).
      with(c1, hash_including(reload_step: false, reload_files: true))

    expect(PipelineChannel).
      to receive(:broadcast_to).
      with(c2, hash_including(reload_step: true, reload_files: true))

    described_class.new(computation: c2).call
  end
end
