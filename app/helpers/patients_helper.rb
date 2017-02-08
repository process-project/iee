# frozen_string_literal: true
module PatientsHelper
  STATUS_MAP = {
    'new' => 'primary',
    'queued' => 'info',
    'running' => 'warning',
    'error' => 'danger',
    'finished' => 'success',
    'aborted' => 'default'
  }.freeze

  def procedure_progress(patient)
    status_number = Patient.procedure_statuses[patient.procedure_status] || 0
    "#{status_number.to_f / (Patient.procedure_statuses.size - 1).to_f * 100}%"
  end

  def computation_status(status)
    label_class = STATUS_MAP[status] || 'default'
    content_tag :div, status.humanize, class: "label label-#{label_class}"
  end

  def execution_time(computation)
    case computation.status
    when 'new', 'queued'
      '-'
    when 'running'
      Time.at(Time.now - computation.created_at).utc.strftime('%Hh %Mm %Ss')
    else
      # TODO: FIXME If possible, use finish time from the computing job
      Time.at(computation.updated_at - computation.created_at).utc.strftime('%Hh %Mm %Ss')
    end
  end
end
