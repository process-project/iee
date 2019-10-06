class Profiles::ComputeSiteProxyController < ApplicationController
    def index
      @compute_site_proxies = ComputeSiteProxy.all
    end

    def new
      @compute_sites = ComputeSite.all
      @compute_site_proxy = ComputeSiteProxy.new
    end

    def create
      ComputeSiteProxy.create(user: current_user, 
                        compute_site: ComputeSite.find(permitted_attributes[:compute_site]),
                        value: permitted_attributes[:value])

      redirect_to profile_compute_site_proxy_index_path
    end

    def edit
      @compute_site_proxy = ComputeSiteProxy.find(params[:id])
    end

    def update
      ComputeSiteProxy.find(params[:id]).update_attributes(value: permitted_attributes[:value])

      redirect_to profile_compute_site_proxy_index_path
    end

    private

    def permitted_attributes
      params.require(:compute_site_proxy).permit(:value, :compute_site)
    end
end
