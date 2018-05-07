# frozen_string_literal: true

class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :pipeline

  validates :status,
            inclusion: { in: %w[created new queued running error finished aborted] }

  validates :deployment,
            inclusion: { in: %w[cluster cloud service] },
            allow_blank: true

  # Disabled until we are able to deal with the steps which are there
  # but are not used in any pipeline right now
  # validates :pipeline_step,
  #           inclusion: { in: Pipeline::FLOWS.values.flatten.uniq.map { |c| c::STEP_NAME } }

  scope :active, -> { where(status: %w[new queued running]) }
  scope :submitted, -> { where(status: %w[queued running]) }
  scope :created, -> { where(status: 'created') }
  scope :not_finished, -> { where(status: %w[created new queued running]) }
  scope :scripted, -> { where(type: 'ScriptedComputation') }
  scope :rimrock, -> { where(deployment: 'cluster') }
  scope :cloud, -> { where(deployment: 'cloud') }
  scope :webdav, -> { where(type: 'WebdavComputation') }
  scope :submitted_rimrock, -> { submitted.rimrock }
  scope :submitted_webdav, -> { submitted.webdav }
  scope :submitted_cloud, -> { submitted.cloud }
  scope :for_patient_status, ->(status) { where(pipeline_step: status) }

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

  def scripted?
    type == 'ScriptedComputation'
  end

  def rimrock?
    deployment == 'cluster'
  end

  def cloud?
    deployment == 'cloud'
  end

  def self.flow_ordered
    where(nil).sort_by(&:flow_index)
  end

  def flow_index
    pipeline.steps.map(&:name).index(pipeline_step)
  end

  def run
    runner.call
  end

  def runnable?
    step.input_present_for?(pipeline)
  end

  private

  def runner
    @runner ||= step.runner_for(self)
  end

  def step
    return nil if pipeline.nil?
    ps = pipeline.steps.find { |step| step.name == pipeline_step }
    Rails.logger.debug("Step runner found this step: #{ps.inspect}")
    ps
  end
end
