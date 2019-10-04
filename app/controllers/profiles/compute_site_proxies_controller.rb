class Profiles::ComputeSiteProxiesController < ApplicationController
  def show
    @compute_sites = ComputeSite.all
    @compute_site_proxy = ComputeSiteProxy.new()
  end
  def update
    logger = Logger.new(Rails.root.join('log', 'alfa.log'))
    logger.info("not funny: Twoj stary byl w metodzie update")
    # render :show
  end
end
