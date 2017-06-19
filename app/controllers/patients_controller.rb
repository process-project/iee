# frozen_string_literal: true
class PatientsController < ApplicationController
  before_action :set_patients
  before_action :find_and_authorize, only: [:show, :destroy]

  def index; end

  def show
    @pipelines = @patient.pipelines.includes(:computations).order(:iid)
    @new_computation = Computation.new(
      pipeline_step: @patient.procedure_status
    )
  end

  def new
    @patient = Patient.new
    authorize(@patient)
  end

  def create
    new_patient = Patient.new(permitted_attributes(Patient))
    authorize(new_patient)

    @patient = Patients::Create.new(current_user, new_patient).call

    if @patient.valid?
      @patient.execute_data_sync(current_user)
      redirect_to @patient, notice: I18n.t('patients.create.success')
    else
      render :new
    end
  end

  def destroy
    if Patients::Destroy.new(current_user, @patient).call
      redirect_to patients_path,
                  notice: I18n.t('patients.destroy.success',
                                 case_number: @patient.case_number)
    else
      render :show,
             notice: I18n.t('patients.destroy.failure',
                            case_number: @patient.case_number)
    end
  end

  private

  def set_patients
    @patients = policy_scope(Patient).all
  end

  def find_and_authorize
    @patient = @patients.find(params[:id])
    authorize(@patient)
  end
end
