# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Proxy do
  it 'checks for proxy validity' do
    proxy = Proxy.new(double(proxy: outdated_proxy))

    expect(proxy).to_not be_valid
  end

  def outdated_proxy
    File.read(Rails.root.join('spec', 'support', 'proxy', 'outdated'))
  end
end
