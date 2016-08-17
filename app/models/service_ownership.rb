# frozen_string_literal: true
class ServiceOwnership < ApplicationRecord
  belongs_to :service
  belongs_to :user

  validates :service, uniqueness: { scope: :user }
  validates :service, :user, presence: true
end
