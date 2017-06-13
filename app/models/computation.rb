# frozen_string_literal: true
class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :pipeline

  validates :status,
            inclusion: { in: %w(created new queued running error finished aborted) }

  validates :pipeline_step,
            inclusion: { in: Pipeline::STEPS.map { |c| c::STEP_NAME } }

  scope :active, -> { where(status: %w(new queued running)) }
  scope :submitted, -> { where(status: %w(queued running)) }
  scope :submitted_rimrock, -> { submitted.where(type: 'RimrockComputation') }
  scope :submitted_webdav, -> { submitted.where(type: 'WebdavComputation') }
  scope :for_patient_status, ->(status) { where(pipeline_step: status) }

  delegate :runnable?, :run, to: :runner

  def active?
    %w(new queued running).include? status
  end

  def finished?
    %w(error finished aborted).include? status
  end

  def self.type_for_patient_status(status)
    case status
    when 'imaging_uploaded' then 'segmentation'
    when 'virtual_model_ready' then 'blood_flow_simulation'
    when 'after_parameter_estimation' then 'heart_model_computation'
    end
  end

  def to_param
    pipeline_step
  end

  private

  def runner
    @runner ||= runner_class.new(pipeline)
  end

  def runner_class
    Pipeline::STEPS.find { |s| s::STEP_NAME == pipeline_step }
  end
end
