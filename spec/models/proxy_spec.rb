# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Proxy do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  it 'checks for proxy validity' do
    proxy = Proxy.new(double(proxy: outdated_proxy))

    expect(proxy).to_not be_valid

    travel_to Time.zone.local(2017, 1, 17, 18, 0, 0)
    expect(proxy).to be_valid

    travel_back
  end

  it 'can check validity even for corrupted proxy' do
    proxy = Proxy.new(double(proxy: 'a b c'))

    expect(proxy).to_not be_valid
  end
end
