# frozen_string_literal: true
class Patient < ApplicationRecord
  enum procedure_status: [
    :not_started,
    :imaging_uploaded,
    :segmentation_ready,
    :virtual_model_ready,
    :after_blood_flow_simulation,
    :after_parameter_estimation,
    :after_heart_simulation
  ]

  has_many :data_files, dependent: :destroy
  has_many :pipelines, dependent: :destroy

  validates :case_number, :procedure_status, presence: true
  validates :case_number, uniqueness: true

  default_scope { order('case_number asc') }

  after_touch :update_procedure_status

  def execute_data_sync(user)
    WebdavDataFileSynchronizer.new(self, user).call
  end

  def working_dir
    File.join(Rails.env, 'patients', case_number, '/')
  end

  def working_url
    File.join(Webdav::FileStore.url, Webdav::FileStore.path, working_dir)
  end

  def inputs_dir(prefix = working_dir)
    File.join(prefix, 'inputs', '/')
  end

  def inputs_url
    inputs_dir(working_url)
  end

  def pipelines_dir(prefix = working_dir)
    File.join(prefix, 'pipelines', '/')
  end

  def pipelines_url
    pipelines_dir(working_url)
  end

  private

  # rubocop:disable CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  def update_procedure_status
    data_files.reload
    # This should go from the most advanced status to the least advanced one.
    if heart_model_output_exist? then after_heart_simulation!
    elsif estimated_parameters_exist? then after_parameter_estimation!
    elsif blood_flow_result_and_model_exist? then after_blood_flow_simulation!
    elsif fluid_and_ventricle_virtual_models_exist? then virtual_model_ready!
    elsif segmentation_output_exist? then segmentation_ready!
    elsif segmentation_input_exist? then imaging_uploaded!
    else not_started!
    end
  end

  def fluid_and_ventricle_virtual_models_exist?
    data_files.any?(&:fluid_virtual_model?) &&
      data_files.any?(&:ventricle_virtual_model?)
  end

  def blood_flow_result_and_model_exist?
    data_files.reload.any?(&:blood_flow_result?) &&
      data_files.reload.any?(&:blood_flow_model?)
  end

  def estimated_parameters_exist?
    data_files.reload.any?(&:estimated_parameters?)
  end

  def heart_model_output_exist?
    data_files.reload.any?(&:heart_model_output?)
  end

  def segmentation_input_exist?
    data_files.reload.any?(&:image?)
  end

  def segmentation_output_exist?
    data_files.reload.any?(&:segmentation_result?)
  end
end
