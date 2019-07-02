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
    :off_mesh,
    :graphics,
    :truncated_off_mesh,
    :response_surface,
    :pressure_drops,
    :parameter_optimization_result,
    :data_series_1,
    :data_series_2,
    :data_series_3,
    :data_series_4,
    :generic_type,
    :validation_type
  ]

  belongs_to :project, touch: true

  belongs_to :output_of,
             optional: true,
             inverse_of: :outputs,
             class_name: 'Pipeline'

  belongs_to :input_of,
             optional: true,
             inverse_of: :inputs,
             class_name: 'Pipeline'

  validates :name, :data_type, :project, presence: true

  def path
    File.join(root_path, name)
  end

  def url
    File.join(root_url, name)
  end

  def content(user)
    Webdav::FileStore.new(user).get_file_to_memory(path)
  end

  def comparable?
    estimated_parameters? || heart_model_output? || off_mesh? || graphics?
  end

  def similar?(other_data_file)
    name == other_data_file.name
  end

  private

  def root_path
    output_of&.outputs_dir ||
      input_of&.inputs_dir ||
      project.inputs_dir
  end

  def root_url
    output_of&.outputs_url ||
      input_of&.inputs_url ||
      project.inputs_url
  end
end
