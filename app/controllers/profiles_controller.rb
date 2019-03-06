# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show; end

  def update
    if current_user.update(user_params)
      flash[:notice] = t('profiles.update.success')
    else
      flash[:alert] = t('profiles.update.failure')
    end

    render action: 'show'
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end
end
