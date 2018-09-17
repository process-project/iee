# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rimrock::TriggerUpdateJob do
  it 'triggers update for all users with active jobs' do
    u1, u2 = create_list(:user, 2)

    create(:rimrock_computation, status: 'running', user: u1)
    create(:webdav_computation, status: 'new', user: u1)
    create(:rimrock_computation, status: 'finished', user: u2)
    create(:webdav_computation, status: 'running', user: u2)

    expect(Rimrock::UpdateJob).to receive(:perform_later).with(u1)
    expect(Rimrock::UpdateJob).to_not receive(:perform_later).with(u2)
    expect(Webdav::UpdateJob).to receive(:perform_later).with(u2)
    expect(Webdav::UpdateJob).to_not receive(:perform_later).with(u1)

    described_class.perform_now
  end

  it 'refreshes job states after detecting required input files' do
    c = create(:rimrock_computation,
               status: 'created',
               pipeline_step: 'heart_model_calculation',
               pipeline: build(:pipeline, flow: 'unused_steps'))

    expect(ComputationUpdater).to receive(:new).with(c).and_call_original
    allow(c.step).to receive(:input_present_for?).with(c.pipeline).and_return(true)
    allow_any_instance_of(Proxy).to receive(:valid?).and_return(true)
    expect_any_instance_of(Computation).to receive(:run)

    described_class.perform_now
  end
end
