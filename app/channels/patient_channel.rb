# frozen_string_literal: true

class PatientChannel < ApplicationCable::Channel
  def subscribed
    stream_for patient
  end

  private

  def patient
    Patient.find_by(case_number: params[:patient])
  end
end
