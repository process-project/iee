# frozen_string_literal: true
class AccessMethod < ApplicationRecord
  include CheckExistenceConcern

  has_many :access_policies, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
