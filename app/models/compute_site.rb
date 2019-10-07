class ComputeSite < ApplicationRecord
	has_many :compute_site_proxies, :dependent => :delete_all
	has_many :users, through: :compute_site_proxies
end
