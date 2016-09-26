# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_raven_context, if: :sentry_enabled?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_confirmation_data

  rescue_from ActiveRecord::RecordNotFound do
    redirect_back fallback_location: root_path,
                  alert: I18n.t('record_not_found'),
                  status: 404
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    redirect_back fallback_location: root_path,
                  alert: not_authorized_msg(exception),
                  status: 403
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  def set_confirmation_data
    if current_user&.supervisor?
      @users = {}
      @users[:confirmed] = User.where(approved: true)
      @users[:not_confirmed] = User.where(approved: false)
      @user_confirmations = @users[:not_confirmed].exists?
    end
  end

  private

  def set_raven_context
    if current_user
      Raven.user_context(id: current_user.id,
                         email: current_user.email,
                         username: current_user.name)
    end
    Raven.extra_context(params: params.to_h, url: request.url)
  end

  def sentry_enabled?
    Rails.env.production?
  end

  def not_authorized_msg(exception)
    policy_name = exception.policy.class.to_s.underscore

    I18n.t("#{policy_name}.#{exception.query}", scope: 'pundit', defult: :defult)
  end
end
