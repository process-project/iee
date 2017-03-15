# frozen_string_literal: true
class Computation < ApplicationRecord
  belongs_to :user
  belongs_to :patient

  validates :user, presence: true
  validates :status, inclusion: { in: %w(new queued running error finished aborted) }
  validates :pipeline_step, inclusion: { in: Patient::PIPELINE.keys.map { |k| k.to_s } }

  scope :active, -> { where(status: %w(new queued running)) }
  scope :for_patient_status, ->(status) { where(pipeline_step: status) }

  def active?
    %w(new queued running).include? status
  end

  def self.type_for_patient_status(status)
    case status
    when 'virtual_model_ready' then 'blood_flow_simulation'
    when 'after_parameter_estimation' then 'heart_model_computation'
    end
  end
end
