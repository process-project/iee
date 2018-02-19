# frozen_string_literal: true

require 'rails_helper'

shared_examples 'runnable step' do
  include ActiveSupport::Testing::TimeHelpers

  it 'set computation start time to now' do
    now = Time.zone.local(2017, 1, 2, 7, 21, 34)
    travel_to now do
      subject.call

      expect(subject.computation.started_at).to eq now
    end
  end

  it 'sent notification after computation is started' do
    expect(updater).to receive(:call)

    subject.call
  end

  it 'changes computation status to :new' do
    subject.call

    expect(computation.status).to eq 'new'
  end
end
