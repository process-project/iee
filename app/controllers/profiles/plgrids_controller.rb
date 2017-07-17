# frozen_string_literal: true

module Profiles
  class PlgridsController < ApplicationController
    def show
      authorize(:plgrid)
      @proxy = Proxy.new(current_user) if current_user.proxy.present?
    end

    def destroy
      authorize(:plgrid)
      if current_user.update_attributes(plgrid_login: nil, proxy: nil)
        redirect_to profile_path
      else
        flash[:alert] = t('profiles.plgrids.destroy.failure')
        render 'show'
      end
    end
  end
end
