# frozen_string_literal: true

# rubocop:disable ClassLength
class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :pipeline

  belongs_to :compute_site, optional: true
  belongs_to :src_compute_site, class_name: 'ComputeSite', optional: true
  belongs_to :dest_compute_site, class_name: 'ComputeSite', optional: true

  validates :status,
            inclusion: { in: %w[created new queued running error finished aborted] }

  # Disabled until we are able to deal with the steps which are there
  # but are not used in any pipeline right now
  # validates :pipeline_step,
  #           inclusion: { in: Pipeline::FLOWS.values.flatten.uniq.map { |c| c::STEP_NAME } }

  scope :active, -> { where(status: %w[new queued running]) }
  scope :submitted, -> { where(status: %w[queued running]) }
  scope :created, -> { where(status: 'created') }
  scope :not_finished, -> { where(status: %w[created new queued running]) }
  scope :rimrock, -> { where(type: 'RimrockComputation') }
  scope :singularity, -> { where(type: 'SingularityComputation') }
  scope :cloudify, -> { where(type: 'CloudifyComputation') }
  scope :rest, -> { where(type: 'RestComputation') }
  scope :lobcder, -> { where(type: 'LobcderComputation') }
  scope :submitted_rimrock, -> { submitted.rimrock }
  scope :submitted_singularity, -> { submitted.singularity }
  scope :submitted_cloudify, -> { submitted.cloudify }
  scope :submitted_lobcder, -> { submitted.lobcder }
  scope :submitted_rest, -> { submitted.rest }
  scope :created_or_submitted_rest, -> { created.rest + submitted.rest }
  scope :for_project_status, ->(status) { where(pipeline_step: status) }

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

  def cloudify?
    type == 'CloudifyComputation'
  end

  def singularity?
    type == 'SingularityComputation'
  end

  def lobcder?
    type == 'LobcderComputation'
  end

  def rest?
    type == 'RestComputation'
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

  def success?
    status == 'finished'
  end

  def error?
    status == 'error'
  end

  def created?
    status == 'created'
  end

  def computed_status
    if success?
      :success
    elsif error?
      :error
    elsif active?
      :running
    else
      :waiting
    end
  end

  def step
    return nil if pipeline.nil?
    pipeline.steps.find { |step| step.name == pipeline_step }
  end

  def need_directory_structure?
    false
  end

  def prev
    comps = pipeline.computations.sort_by(&:id).to_a
    comps[0..-2].zip(comps[1..-1]).each do |prev_c, c|
      return prev_c if c == self
    end

    nil
  end

  def next
    comps = pipeline.computations.sort_by(&:id).to_a
    comps[0..-2].zip(comps[1..-1]).each do |c, next_c|
      return next_c if c == self
    end

    nil
  end

  def uc
    Flow.uc_for(pipeline.flow.to_sym)
  end

  private

  def runner
    @runner ||= step.runner_for(self)
  end
end
# rubocop:enable ClassLength
