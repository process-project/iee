# frozen_string_literal: true

class UserAgent < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
end
