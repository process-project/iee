# frozen_string_literal: true
class PatientsController < ApplicationController
  before_action :set_patients

  def index; end

  def show
    @patient = @patients.find(params[:id])
    @pipelines = @patient.pipelines.order(:iid)
    @new_computation = Computation.new(
      pipeline_step: @patient.procedure_status
    )
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.create(create_params)

    if @patient.valid?
      @patient.execute_data_sync(current_user)
      redirect_to @patient, notice: I18n.t('patients.create.success')
    else
      render :new
    end
  end

  def destroy
    @patient = Patient.find(params[:id])

    if @patient.destroy
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
    # NOTE Here insert the code that decides what Patients the current_user
    # is able to see.
    @patients = Patient.all
  end

  def create_params
    params.require(:patient).permit(:case_number)
  end
end
