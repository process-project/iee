class ComputeSite < ApplicationRecord
	has_many :compute_site_proxy
	has_many :user, through: :compute_site_proxy
end
