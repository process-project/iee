# frozen_string_literal: true
class ComputationsController < ApplicationController
  def show
    @computation = Computation.find(params[:id])

    render partial: 'patients/computation',
           layout: false,
           object: @computation
  end

  def create
    @computation = computation_builder_for(patient.procedure_status).run(patient, current_user)
    redirect_to @computation.patient, notice: 'Computation submitted'
  end

  private

  def computation_builder_for(procedure_status)
    Patient::PIPELINE[procedure_status.to_sym]
  end

  def create_params
    params.require(:computation).permit(:patient_id)
  end

  def patient
    @patient ||= Patient.find(create_params[:patient_id])
  end
end
