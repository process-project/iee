class DataFile < ActiveRecord::Base
  enum data_type: [ :fluid_virtual_model, :ventricle_virtual_model, :blood_flow_result ]

  belongs_to :patient, touch: true

  validates :name, :data_type, :patient, presence: true
end
