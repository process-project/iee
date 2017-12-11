# frozen_string_literal: true

class SynchronizePatientsJob < ApplicationJob
  queue_as :computation

  def perform
    Patients::PatientSynchronizer.new.call
  end
end
