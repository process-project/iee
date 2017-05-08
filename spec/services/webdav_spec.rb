# frozen_string_literal: true
require 'rails_helper'

require 'net/dav'

describe Webdav do
  context 'authentication' do
    before do
      allow(Net::DAV).to receive(:new).and_return(nil)
    end

    let(:url) { 'https://foo.bar' }
    it 'raise error if two authentication methods are provided' do
      expect do
        Webdav.new(
          url,
          headers: { 'Authorization' => 'Bearer tkn' }, username: 'usr', password: 'pwd'
        )
      end.to raise_error(ArgumentError, 'Provide either a :token or :user and :password')
    end
    it 'does not raise if basic auth is used' do
      Webdav.new(url, username: 'user', password: 'password')
    end
    it 'does not raise if JWT is used' do
      Webdav.new(url, headers: { 'Authorization' => 'Bearer token' })
    end
  end
end
