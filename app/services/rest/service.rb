# frozen_string_literal: true
require 'faraday'

module Rest
  class Service
    def initialize(user, options = {})
      @user = user
      @token = user.token
    end

    protected

    attr_reader :user

    def connection
      @logger.info("Inside Rest::Service connection")
      @connection ||= Faraday.new(url: rest_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization: Bearer'] = @token
      end

      @logger.info("connection headers: #{@connection.headers}")
      # @logger.info("connection url: #{@connection.url}")
      return @connection
    end

    private

    def rest_url
      Rails.application.config_for('process')['rest']['host'] + ":" +
      Rails.application.config_for('process')['rest']['port']
    end
  end

  class Exception < RuntimeError
  end
end
