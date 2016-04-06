class PatientsController < ApplicationController
  before_action :set_patients

  def index
  end

  def show
    @patient = @patients.find(params[:id])
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.create(create_params)

    if @patient.valid?
      redirect_to @patient, notice: 'New patient case added.'
    else
      render :new
    end
  end

  def destroy
    @patient = Patient.find(params[:id])

    if @patient.destroy
      redirect_to patients_path, notice: "Patient case #{@patient.case_number} was removed."
    else
      render :show, notice: "Unable to remove patient case #{@patient.case_number}."
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
