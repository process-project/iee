# frozen_string_literal: true

module Api
  class ServiceController < Api::ApplicationController
    attr_reader :service

    before_action :authenticate_service!

    private

    def authenticate_service!
      @service = token && Service.find_by(token: token)

      service_invalid! unless @service
    end

    def token
      request.headers['HTTP_X_SERVICE_TOKEN']
    end

    def service_invalid!
      head :unauthorized,
           'WWW-Authenticate' => 'X-SERVICE-TOKEN header is invalid'
    end
  end
end
