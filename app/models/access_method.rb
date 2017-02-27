# frozen_string_literal: true
class AccessMethod < ApplicationRecord
  include CheckExistenceConcern

  belongs_to :service, optional: true
  has_many :access_policies, dependent: :destroy

  validates :name,
            presence: true,
            uniqueness: { scope: :service_id, case_sensitive: false }

  scope :global, -> { where service_id: nil }
end
