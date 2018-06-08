# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      super

      u = user

      Audit.create(ip: request.remote_ip, user_agent: request.user_agent,
                   accept_language: request.env['HTTP_ACCEPT_LANGUAGE'],
                   user: u)

      UserAuditor.new(u).call
    end

    private

    def user
      u = User.find_by(email: request.filtered_parameters['user']['email'])
      raise StandardError('[BUG] Unknown user authenticated !?') if u.nil?

      u
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path
    end
  end
end
