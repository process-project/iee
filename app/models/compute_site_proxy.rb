class ComputeSiteProxy < ApplicationRecord
	belongs_to :user
	belongs_to :compute_site
  validates :compute_site_id, uniqueness: {scope: :user_id}

  def compute_site_name
    compute_site.name
  end
end
