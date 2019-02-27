# frozen_string_literal: true

class DataFileType < ApplicationRecord
  validates :data_type, presence: true
  validates :pattern, presence: true

  def match?(file_name)
    Regexp.new(pattern).match?(file_name)
  end
end
