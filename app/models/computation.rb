class Computation < ActiveRecord::Base
  belongs_to :user
  belongs_to :patient

  validates :script, presence: true
  validates :user, presence: true
  validates :working_directory, uniqueness: true
end
