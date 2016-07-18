class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :patient

  validates :script, presence: true
  validates :user, presence: true

  scope :active, -> { where(status: %w(new queued running)) }

  def active?
    %w(new queued running).include? status
  end
end
