module Api
  class ApplicationController < ActionController::Base
    include Pundit

    protect_from_forgery with: :null_session
    before_action :authenticate_user!
    before_action :destroy_session

    def destroy_session
      request.session_options[:skip] = true
    end

    protected

    def api_error(status: 500, errors: [])
      head status: status and return if errors.empty?
      render json: jsonapi_format(errors).to_json, status: status
    end

    def jsonapi_format(errors)
      return errors if errors.is_a?(String)
      errors_hash = {}
      errors.messages.each do |attribute, error|
        array_hash = []
        error.each { |e| array_hash << { attribute: attribute, message: e } }
        errors_hash.merge!({ attribute => array_hash })
      end

      return errors_hash
    end
  end
end
