# frozen_string_literal: true
class ComputationsController < ApplicationController
  def show
    @computation = Computation.find(params[:id])

    render partial: 'patients/computation',
           layout: false,
           object: @computation
  end

  def create
    params[:script] = 'vapor_script.sh'
    @computation = Computation.create(
      create_params.merge(
        user: current_user,
        script: ComputationScriptGenerator.new(patient, current_user).script
      )
    )
    Rimrock::StartJob.perform_later @computation
    redirect_to @computation.patient, notice: 'Computation submitted'
  end

  private

  def create_params
    params.require(:computation).permit(:patient_id, :computation_type)
  end

  def patient
    @patient ||= Patient.find(params[:computation][:patient_id])
  end
end
