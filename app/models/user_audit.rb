class UserAudit < ApplicationRecord
  belongs_to :user

  validates :ip, presence: true

  def ip_cc
    db = MaxMindDB.new(Rails.application.config_for('eurvalve')['maxmind']['db'])

    unless db.nil?
      l = db.lookup self.ip
      return l.country.iso_code if l.found?
    end

    nil
  end
end
