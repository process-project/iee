# frozen_string_literal: true
class DataFile < ApplicationRecord
  enum data_type: [
    :fluid_virtual_model,
    :ventricle_virtual_model,
    :blood_flow_result,
    :blood_flow_model,
    :estimated_parameters,
    :heart_model_output
  ]

  belongs_to :patient, touch: true

  validates :name, :data_type, :patient, presence: true

  def self.synchronizer_class
    synchronizer_klass_name = Rails.application.config_for('eurvalve')['data_synchronizer']
    @synchronizer = synchronizer_klass_name.constantize
  end
end
