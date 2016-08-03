# frozen_string_literal: true
require 'base64'
require 'faraday'

class ProxyService
  def initialize(user, service_url, options = {})
    @user = user
    @service_url = service_url
    @proxy = encode_proxy(user&.proxy)
    @connection = options[:connection]
  end

  protected

  def connection
    @connection ||= Faraday.new(url: @service_url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers['PROXY'] = @proxy
    end
  end

  private

  def encode_proxy(proxy)
    proxy && Base64.encode64(proxy).gsub!(/\s+/, '')
  end
end
