# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include Pundit

    before_action :authenticate_user!
    before_action :destroy_session

    rescue_from Pundit::NotAuthorizedError, with: :forbidden
    rescue_from Pundit::NotDefinedError, with: :not_found
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

    def permitted_attributes(record, action = action_name)
      policy = policy(record)
      method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
                      "permitted_attributes_for_#{action}"
                    else
                      'permitted_attributes'
                    end
      pundit_params_for(record).permit(*policy.public_send(method_name))
    end

    def pundit_params_for(_record)
      params.require(:data).require(:attributes)
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

    def not_found
      api_error(status: :not_found)
    end
  end
end
