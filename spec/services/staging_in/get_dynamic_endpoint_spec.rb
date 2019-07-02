# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StagingIn::GetDynamicEndpoint do
  xit 'enpoint has required entries' do
    endpoint = described_class.new.call

    expect(endpoint['staging_in_host']).to_not be_nil
    expect(endpoint['staging_in_port']).to match(/^[0-9]*$/)
    expect(endpoint['token_header']).to_not be_nil
    expect(endpoint['lobcder_api_access_token']).to_not be_nil
  end
end
