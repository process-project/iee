module Api
  class SessionsController < Api::ApplicationController
    skip_before_action :authenticate_user!

    def create
      user = User.find_by(email: create_params[:email])
      if user && user.valid_password?(create_params[:password])
        @current_user = user
        render json: user_details, status: 201
      else
        return api_error(status: 401)
      end
    end

    private

    def user_details
      {
        user: {
          name: @current_user.name,
          email: @current_user.email,
          token: @current_user.token
        }
      }
    end

    def create_params
      params.require(:user).permit(:email, :password)
    end
  end
end
