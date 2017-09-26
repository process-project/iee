# frozen_string_literal: true

module ComputationsHelper
  include PatientsHelper

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

  def source_comparison_link(from_comp, to_comp)
    repo = computation_repo(from_comp)
    link_to source_comparison_link_text(from_comp, to_comp),
            "https://#{gitlab_host}/#{repo}/compare/#{from_comp.revision}...#{to_comp.revision}",
            target: '_blank'
  end

  def source_link(computation)
    if computation.revision
      repo = computation_repo(computation)
      link_to computation.revision,
              "https://#{gitlab_host}/#{repo}/tree/#{computation.revision}"
    end
  end

  private

  def computation_repo(computation)
    Rails.application.config_for('eurvalve')['git_repos'][computation.pipeline_step]
  end

  def gitlab_host
    Rails.application.config_for('application')['gitlab']['host']
  end

  def source_comparison_link_text(from_comp, to_comp)
    I18n.t(
      'patients.comparisons.show.source_comparison_link',
      computation_step: t("steps.#{from_comp.pipeline_step}.title"),
      compared_revision: "#{from_comp.tag_or_branch}:#{from_comp.revision}",
      compare_to_revision: "#{to_comp.tag_or_branch}:#{to_comp.revision}"
    )
  end

  def alert_class_postfix(computation)
    case computation.status
    when 'error' then 'danger'
    when 'finished' then 'success'
    when 'aborted' then 'warning'
    else 'info'
    end
  end

  # rubocop:disable Metrics/MethodLength
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
  # rubocop:enable Metrics/MethodLength

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
