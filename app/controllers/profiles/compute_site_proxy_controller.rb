# frozen_string_literal: true

module Profiles
  class ComputeSiteProxyController < ApplicationController
    def index
      @compute_site_proxies = ComputeSiteProxy.all
    end

    def new
      @compute_sites = ComputeSite.all
      @compute_site_proxy = ComputeSiteProxy.new
    end

    def create
      if !create_proxy
        flash[:alert] = 'Unable to create compute site proxy'
        redirect_to new_profile_compute_site_proxy_path
      else
        flash[:notice] = 'Compute site proxy added successfully'
        redirect_to profile_compute_site_proxy_index_path
      end
    end

    def edit
      @compute_site_proxy = ComputeSiteProxy.find(params[:id])
    end

    def update
      if !update_proxy
        flash[:alert] = 'Unable to update compute site proxy'
        redirect_to edit_profile_compute_site_proxy_path
      else
        flash[:notice] = 'Compute site proxy updated successfully'
        redirect_to profile_compute_site_proxy_index_path
      end
    end

    private

    def create_proxy
      ComputeSiteProxy.create user: current_user, 
                              compute_site: ComputeSite.find(permitted_attributes[:compute_site]), 
                              value: permitted_attributes[:value]
    end

    def update_proxy
      ComputeSiteProxy.find(params[:id]).update_attributes(value: permitted_attributes[:value])
    end

    def permitted_attributes
      params.require(:compute_site_proxy).permit(:value, :compute_site)
    end
  end
end
