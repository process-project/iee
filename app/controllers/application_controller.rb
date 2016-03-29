class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_confirmation_data

  protected

  def layout_by_resource
    if devise_controller?
      "login"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
  end
  
  def set_confirmation_data
    if view_context.supervisor?
      @users = {}
      @users[:confirmed] = User.where(approved: true)
      @users[:not_confirmed] = User.where(approved: false)
      @user_confirmations = @users[:not_confirmed].exists?
    end
  end
end
