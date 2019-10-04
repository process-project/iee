class ComputeSite < ApplicationRecord
	has_many :compute_site_proxies
	has_many :users, through: :compute_site_proxies
end
