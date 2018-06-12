# frozen_string_literal: true

class Ip < ApplicationRecord
  belongs_to :user

  validates :address, presence: true

  def cc
    db = MaxMindDB.new(Rails.application.config_for('eurvalve')['maxmind']['db'])

    unless db.nil?
      l = db.lookup address
      return l.country.iso_code if l.found?
    end

    nil
  end
end
