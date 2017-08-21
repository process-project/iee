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

  def source_comparison_link(compared_computation, compare_to_computation)
    repo = Rails.application.config_for('eurvalve')['git_repos']['heart_model_calculation']
    link_text = I18n.t(
      'patients.comparisons.show.source_comparison_link',
      computation_step: t("patients.pipelines.computations.show.#{compared_computation.pipeline_step}.title"),
      compared_revision: "#{compared_computation.tag_or_branch}:#{compared_computation.revision}",
      compare_to_revision: "#{compare_to_computation.tag_or_branch}:#{compare_to_computation.revision}"
    )
    link_url = "https://gitlab.com/#{repo}/compare/#{compared_computation.revision}...#{compare_to_computation.revision}"
    link_to link_text, link_url, target: '_blank'
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
