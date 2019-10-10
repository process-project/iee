# frozen_string_literal: true

module Profiles
  module ComputeSiteProxyHelper
    def unset_compute_sites
      all_compute_sites = ComputeSite.all.to_set
      temp = ComputeSiteProxy.where(user: current_user).map(&:compute_site)
      set_compute_sites = temp.to_set

      all_compute_sites ^ set_compute_sites
    end
  end
end
