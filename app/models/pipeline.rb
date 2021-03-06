# frozen_string_literal: true

class Pipeline < ApplicationRecord
  enum mode: [:automatic, :manual]

  belongs_to :project
  belongs_to :user

  has_many :computations,
           dependent: :destroy

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true
  validates :mode, presence: true
  validates :flow, inclusion: { in: Flow.types.map(&:to_s) }

  scope :automatic, -> { where(mode: :automatic) }
  scope :latest, ->(nr = 3) { reorder(created_at: :desc).limit(nr) }

  def dir_name
    "pipeline_#{SecureRandom.hex}" # TODO: add dateTime String to name
  end

  def steps
    Flow.steps(flow)
  end

  def to_param
    iid.to_s
  end

  def status
    @status ||= calculate_status
  end

  def owner_name
    user&.name || '(deleted user)'
  end

  def uc
    Flow.uc_for(flow)
  end

  private

  def calculate_status
    if computations.all?(&:success?)
      :success
    elsif computations.any?(&:error?)
      :error
    elsif computations.any?(&:active?)
      :running
    else
      :waiting
    end
  end

  def set_iid
    self.iid = project.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end
