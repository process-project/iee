# frozen_string_literal: true

require 'faraday'

module Rest
  class Service
    def initialize(user, _options = {})
      @user = user
    end

    protected

    def connection
      @connection ||= Faraday.new(url: rest_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = 'Bearer ' + @user.token
      end
    end

    def parse(body)
      JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      return {}
    end

    private

    def rest_url
      Rails.application.config_for('process')['rest']['host'] + ':' +
        Rails.application.config_for('process')['rest']['port']
    end
  end

  class Exception < RuntimeError
  end
end
