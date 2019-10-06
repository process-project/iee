module Profiles
	class ComputeSiteProxiesController < ApplicationController
	  def show
	    @compute_sites = ComputeSite.all.to_a
	    @compute_site_proxy = ComputeSiteProxy.new
	  end

	  def update
	  	@compute_sites = ComputeSite.all.to_a
	    logger = Logger.new(Rails.root.join('log', 'alfa.log'))
	    logger.info("not funny: Twoj stary byl w metodzie update")
	    # logger.info("params: #{params}")
	    logger.info("value: #{value}")
	    logger.info("compute_sites: #{@compute_sites}")
	    logger.info("compute_site: #{compute_site}")
	    logger.info("current_user: #{current_user}")
	    
	    ComputeSiteProxy.create user: current_user,
	    												compute_site: compute_site,
	    												value: value
	    render :show
	  end

	  private

	  def value
	  	permitted = params.require(:compute_site_proxy).permit(:value)
	  	permitted.to_h[:value]
	  end

	  def compute_site
	  	permitted = params.require(:compute_site_proxy).permit(:compute_site)
	  	index = permitted.to_h[:compute_site].to_i - 1
	  	@compute_sites[index]
	  end
	end
end
