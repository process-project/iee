class ComputeSiteProxy < ApplicationRecord
	belongs_to :user
	belongs_to :compute_site
  validates :compute_site_id, uniqueness: {scope: :user_id}
end
