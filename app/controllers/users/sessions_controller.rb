# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      super

      u = User.find_by(email: request.filtered_parameters["user"]["email"])
      raise StandardError('[BUG] Unknown user authenticated !?') if u.nil?

      UserAudit.create(ip: request.remote_ip, user_agent: request.user_agent,
                       accept_language: request.env['HTTP_ACCEPT_LANGUAGE'],
                       user: u)

      # FIXME: !!! Call
    end

    private

    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path
    end
  end
end
