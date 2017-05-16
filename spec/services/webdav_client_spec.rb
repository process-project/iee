# frozen_string_literal: true
require 'rails_helper'

require 'net/dav'

describe WebdavClient do
  context 'authentication' do
    let(:dav) { double('dav') }

    before do
      allow(Net::DAV).to receive(:new).and_return(dav)
      allow(dav).to receive(:verify_server=)
    end

    let(:url) { 'https://foo.bar' }

    it 'raise error if two authentication methods are provided' do
      expect do
        WebdavClient.new(
          url,
          headers: { 'Authorization' => 'Bearer tkn' }, username: 'usr', password: 'pwd'
        )
      end.to raise_error(ArgumentError, 'Provide either a :token or :user and :password')
    end

    it 'does not raise if basic auth is used' do
      WebdavClient.new(url, username: 'user', password: 'password')
    end

    it 'does not raise if JWT is used' do
      WebdavClient.new(url, headers: { 'Authorization' => 'Bearer token' })
    end

    it 'sets verify server to true by default' do
      expect(dav).to receive(:verify_server=).with true
      WebdavClient.new(url, username: 'user', password: 'password')
    end

    it 'sets verify server to value specified in options' do
      verify_server = false
      expect(dav).to receive(:verify_server=).with verify_server
      WebdavClient.new(url, username: 'user', password: 'password', verify_server: verify_server)
    end
  end
end
