# frozen_string_literal: true
module ComputationsHelper
  include PatientsHelper

  def infrastructure_file_path(path)
    path&.gsub('download/', 'files/')
  end

  def run_status(computation)
    clazz = 'circle-o'
    additional_clazz = nil

    clazz, additional_clazz = runnable_run_status(computation) if computation.runnable?

    icon(clazz, class: additional_clazz, title: computation_tooltip_text(computation))
  end

  def alert_computation_class(computation)
    "alert-#{alert_class_postfix(computation)}"
  end

  private

  def alert_class_postfix(computation)
    case computation.status
    when 'error' then 'danger'
    when 'finished' then 'success'
    when 'aborted' then 'warning'
    else 'info'
    end
  end

  def runnable_run_status(computation)
    if computation.active?
      ['circle-o-notch', 'fa-spin']
    elsif computation.status == 'finished'
      ['check-circle-o', nil]
    elsif computation.status == 'error'
      ['times-circle-o', nil]
    else
      ['circle', nil]
    end
  end

  def computation_tooltip_text(computation)
    if computation.runnable?
      I18n.t('patients.pipelines.computations.show.'\
             "#{computation.pipeline_step}.#{computation.status}")
    else
      I18n.t('patients.pipelines.computations.show.'\
             "#{computation.pipeline_step}.cannot_start")
    end
  end
end
