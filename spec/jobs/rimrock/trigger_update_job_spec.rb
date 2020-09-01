# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rimrock::TriggerUpdateJob do
  it 'triggers update for all users with active jobs' do
    u1, u2 = create_list(:user, 2)

    create(:rimrock_computation, status: 'running', user: u1)
    create(:rimrock_computation, status: 'finished', user: u2)

    expect(Rimrock::UpdateJob).to receive(:perform_later).with(u1)
    expect(Rimrock::UpdateJob).to_not receive(:perform_later).with(u2)

    described_class.perform_now
  end
end
