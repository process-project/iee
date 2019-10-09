# frozen_string_literal: true

class ComputeSiteProxy < ApplicationRecord
  belongs_to :user
  belongs_to :compute_site

  validates :compute_site_id, presence: true
  validates :compute_site_id, uniqueness: { scope: :user_id }
  validates :user_id, presence: true
  validates :value, presence: true

  delegate :name, to: :compute_site, prefix: :compute_site

  # def compute_site_name
  #   compute_site.name
  # end
end
