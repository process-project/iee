# frozen_string_literal: true
class ComputationsController < ApplicationController
  def show
    @computation = Computation.find(params[:id])

    render partial: 'patients/computation',
           layout: false,
           object: @computation
  end

  def create
    @computation = Patient::PIPELINE[patient.procedure_status.to_sym].run(patient, current_user)
    redirect_to @computation.patient, notice: 'Computation submitted'
  end

  private

  def create_params
    params.require(:computation).permit(:patient_id)
  end

  def patient
    @patient ||= Patient.find(params[:computation][:patient_id])
  end
end
