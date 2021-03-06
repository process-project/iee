# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include Pundit

    before_action :authenticate_user!
    before_action :destroy_session
    rescue_from Pundit::NotAuthorizedError, with: :forbidden

    def destroy_session
      request.session_options[:skip] = true
    end

    protected

    def api_error(status: 500, errors: [])
      head(status) && return if errors.empty?
      render json: jsonapi_format(errors).to_json, status: status
    end

    def jsonapi_format(errors)
      return errors if errors.is_a?(String)
      errors_hash = {}
      errors.messages.each do |attribute, error|
        array_hash = []
        error.each { |e| array_hash << { attribute: attribute, message: e } }
        errors_hash.merge!(attribute => array_hash)
      end

      errors_hash
    end

    private

    def authenticate_user!
      head :unauthorized, 'WWW-Authenticate' => error_401_message unless current_user
    end

    def error_401_message
      msg = 'Bearer realm="example"'
      msg += ', error="invalid_token"' if request.env['HTTP_AUTHORIZATION']

      msg
    end

    def forbidden
      api_error(status: :forbidden)
    end
  end
end
