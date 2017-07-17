# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rimrock::StartJob do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  it 'triggers user computations update' do
    travel_to valid_proxy_time

    user = User.new(proxy: outdated_proxy)
    computation = double(user: user)
    start = instance_double(Rimrock::Start)

    expect(start).to receive(:call)
    allow(Rimrock::Start).to receive(:new).with(computation).and_return(start)

    described_class.perform_now(computation)
    travel_back
  end
end
