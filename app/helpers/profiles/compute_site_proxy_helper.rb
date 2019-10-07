# frozen_string_literal: true

module Profiles::ComputeSiteProxyHelper
  def unset_compute_sites
    all_compute_sites = ComputeSite.all.to_set
    set_compute_sites = ComputeSiteProxy.where(user: current_user).map {|csp| csp.compute_site}.to_set

    all_compute_sites ^ set_compute_sites
  end
end
