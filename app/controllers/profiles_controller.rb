# frozen_string_literal: true
class ProfilesController < ApplicationController
  def show
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = 'Your profile has been updated'
    else
      flash[:alert] = 'Unable to update profile'
    end

    render action: 'show'
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end
end
