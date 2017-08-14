# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rimrock::UpdateJob do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  it 'triggers user computations update' do
    travel_to valid_proxy_time

    user = User.new(proxy: outdated_proxy)
    update = instance_double(Rimrock::Update)

    expect(update).to receive(:call)
    allow(Rimrock::Update).
      to receive(:new).
      with(user, on_finish_callback: PipelineUpdater, updater: ComputationUpdater).
      and_return(update)

    described_class.perform_now(user)
    travel_back
  end
end
