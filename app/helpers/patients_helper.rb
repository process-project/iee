module PatientsHelper
  def procedure_progress(patient)
    status_number = Patient.procedure_statuses[patient.procedure_status] || 0
    "#{status_number.to_f / (Patient.procedure_statuses.size - 1).to_f * 100}%"
  end

  def computation
    @computation ||= Computation.new
  end
end
