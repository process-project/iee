# frozen_string_literal: true

module PatientsHelper
  STATUS_MAP = {
    created: { type: 'primary', bgcolor: 'bg-blue' },
    new: { type: 'primary', bgcolor: 'bg-blue' },
    runnable: { type: 'primary', bgcolor: 'bg-blue' },
    queued: { type: 'info', bgcolor: 'bg-blue-sky' },
    running: { type: 'warning', bgcolor: 'bg-orange' },
    error: { type: 'danger', bgcolor: 'bg-red' },
    finished: { type: 'success', bgcolor: 'bg-green' },
    aborted: { type: 'default', bgcolor: 'bg-purple' }
  }.freeze

  def computation_progress(computation, i)
    slice = (1.0 / computation.pipeline.computations.count.to_f) * 100.0
    offset = i.to_f * slice
    tag.div(class: "progress-bar #{status_color(computation)}",
            role: 'progressbar',
            title: I18n.t("steps.#{computation.pipeline_step}.title"),
            style: "width: #{slice}%; margin-left: #{offset}%")
  end

  def computation_status(computation)
    status = runnable?(computation) ? 'runnable' : computation.status
    label_class = STATUS_MAP[status.to_sym][:type] || 'default'
    content_tag :div, I18n.t("computation.status_description.#{status}"),
                class: "label label-#{label_class}",
                title: computation.error_message
  end

  def execution_time(computation)
    case computation.status
    when 'created', 'new', 'queued'
      '-'
    when 'running'
      Time.at(Time.now - computation.started_at).utc.strftime('%Hh %Mm %Ss')
    else
      # TODO: FIXME If possible, use finish time from the computing job
      Time.at(computation.updated_at - computation.started_at).utc.strftime('%Hh %Mm %Ss')
    end
  end

  def start_time(computation)
    computation.started_at ? l(computation.started_at, format: :short) : '-'
  end

  private

  def runnable?(computation)
    computation.status == 'created' && computation.runnable?
  end

  def status_color(computation)
    STATUS_MAP[computation.status.to_sym][:bgcolor]
  end
end
