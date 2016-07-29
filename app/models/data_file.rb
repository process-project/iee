# frozen_string_literal: true
class DataFile < ApplicationRecord
  enum data_type: [:fluid_virtual_model, :ventricle_virtual_model, :blood_flow_result, :blood_flow_model]

  belongs_to :patient, touch: true

  validates :name, :data_type, :patient, presence: true
end
