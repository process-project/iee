class Computation < ActiveRecord::Base
  belongs_to :user

  validates :script, presence: true
  validates :user, presence: true
  validates :working_directory, uniqueness: true
end
