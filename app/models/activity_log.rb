# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  validates :message, presence: true
end
