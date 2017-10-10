# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webdav::StartJob do
  let(:computation) { create(:computation, pipeline_step: :segmentation) }

  it 'sets computation status to error if failed' do
    allow(Segmentation::Start).to receive_message_chain('new.call').and_raise
    expect(ComputationUpdater).to receive_message_chain('new.call')

    described_class.perform_now(computation)
    computation.reload

    expect(computation.status).to eq 'error'
  end

  it 'update computation status' do
    allow(Segmentation::Start).to receive_message_chain('new.call')
    expect(ComputationUpdater).to receive_message_chain('new.call')

    described_class.perform_now(computation)
  end
end
