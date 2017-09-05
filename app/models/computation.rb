# frozen_string_literal: true

class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :pipeline

  validates :status,
            inclusion: { in: %w[created new queued running error finished aborted] }

  validates :pipeline_step,
            inclusion: { in: Pipeline::FLOWS.values.flatten.uniq.map { |c| c::STEP_NAME } }

  scope :active, -> { where(status: %w[new queued running]) }
  scope :submitted, -> { where(status: %w[queued running]) }
  scope :created, -> { where(status: 'created') }
  scope :not_finished, -> { where(status: %w[created new queued running]) }
  scope :rimrock, -> { where(type: 'RimrockComputation') }
  scope :webdav, -> { where(type: 'WebdavComputation') }
  scope :submitted_rimrock, -> { submitted.rimrock }
  scope :submitted_webdav, -> { submitted.webdav }
  scope :for_patient_status, ->(status) { where(pipeline_step: status) }

  delegate :runnable?, :run, to: :runner
  delegate :mode, :manual?, :automatic?, to: :pipeline

  def active?
    %w[new queued running].include? status
  end

  def finished?
    %w[error finished aborted].include? status
  end

  def to_param
    pipeline_step
  end

  def rimrock?
    type == 'RimrockComputation'
  end

  private

  def runner
    @runner ||= runner_class.new(self)
  end

  def runner_class
    return nil if pipeline.nil?
    Pipeline::FLOWS[pipeline.flow.to_sym].find { |s| s::STEP_NAME == pipeline_step }
  end
end
