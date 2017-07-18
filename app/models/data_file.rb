# frozen_string_literal: true
class DataFile < ApplicationRecord
  enum data_type: [
    :image,
    :segmentation_result,
    :fluid_virtual_model,
    :ventricle_virtual_model,
    :blood_flow_result,
    :blood_flow_model,
    :estimated_parameters,
    :heart_model_output,
    :off_mesh
  ]

  belongs_to :patient, touch: true
  belongs_to :pipeline, optional: true

  validates :name, :data_type, :patient, presence: true

  def path
    File.join(pipeline ? pipeline.working_dir : patient.inputs_dir, name)
  end

  def url
    File.join(pipeline ? pipeline.working_url : patient.inputs_url, name)
  end

  def content(user)
    Webdav::FileStore.new(user).get_file_to_memory(path)
  end

  def comparable?
    estimated_parameters? || heart_model_output? || off_mesh?
  end
end
