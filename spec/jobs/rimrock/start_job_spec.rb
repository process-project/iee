# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rimrock::StartJob do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  it 'triggers user computations update' do
    travel_to valid_proxy_time

    user = User.new(proxy: outdated_proxy)
    computation = create(:computation, pipeline_step: 'rom', user: user)

    expect(Rimrock::Start).to receive_message_chain('new.call')
    expect(ComputationUpdater).to receive_message_chain('new.call')

    described_class.perform_now(computation)
    travel_back
  end

  it 'triggers computation update after error' do
    travel_to valid_proxy_time

    user = User.new(proxy: outdated_proxy)
    computation = create(:computation, pipeline_step: 'rom', user: user)

    allow(Rimrock::Start).to receive_message_chain('new.call').and_raise
    expect(ComputationUpdater).to receive_message_chain('new.call')

    described_class.perform_now(computation)
    travel_back
  end
end
