# frozen_string_literal: true

module ComputationsHelper
  include ProjectsHelper

  def infrastructure_file_path(path)
    path&.gsub('download/', 'files/')
  end

  def run_status(computation)
    clazz, additional_clazz = runnable_run_status(computation)
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
    if need_configuration?(computation)
      ['wrench', nil]
    elsif !computation.runnable?
      ['circle-o', nil]
    elsif computation.active?
      ['circle-o-notch', 'fa-spin']
    elsif computation.status == 'finished'
      ['check-circle-o', nil]
    elsif computation.status == 'error'
      ['times-circle-o', nil]
    else
      ['circle', nil]
    end
  end

  def need_configuration?(computation)
    computation.rimrock? &&
      computation.pipeline.automatic? &&
      computation.tag_or_branch.blank?
  end

  def computation_tooltip_text(computation)
    if computation.runnable?
      I18n.t("steps.#{computation.pipeline_step}.#{computation.status}")
    else
      I18n.t("steps.#{computation.pipeline_step}.cannot_start")
    end
  end
end
