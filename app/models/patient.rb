# frozen_string_literal: true
class Patient < ApplicationRecord
  enum procedure_status:
           [:not_started, :imaging_uploaded, :virtual_model_ready, :after_blood_flow_simulation]

  has_many :data_files, dependent: :destroy
  has_many :computations, dependent: :destroy
  has_one :computation

  validates :case_number, :procedure_status, presence: true
  validates :case_number, uniqueness: true

  default_scope { order('case_number asc') }

  after_touch :update_procedure_status

  def execute_data_sync(user)
    DataFileSynchronizer.new(self, user).call
  end

  private

  def update_procedure_status
    data_files.reload
    # This should go from the most advanced status to the least advanced one.
    if blood_flow_result_and_model_exist?
      after_blood_flow_simulation!
    elsif fluid_and_ventricle_virtual_models_exist?
      virtual_model_ready!
    else
      not_started!
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
end
