# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webdav::UpdateJob do
  it 'triggers user webdav computation update' do
    user = build(:user)
    update = instance_double(Webdav::Update)

    expect(update).to receive(:call)
    allow(Webdav::Update).
      to receive(:new).
      with(user, on_finish_callback: PipelineUpdater, updater: ComputationUpdater).
      and_return(update)

    described_class.perform_now(user)
  end
end
