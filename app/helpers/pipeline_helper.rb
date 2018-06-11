# frozen_string_literal: true

module PipelineHelper
  def pipeline_title(pipeline)
    pipeline_icon(pipeline) + ' ' +
      pipeline.name + ' ' +
      content_tag(:small,
                  I18n.t("simple_form.options.pipeline.flow.#{pipeline.flow}") +
                  ' ' +
                  I18n.t('patients.pipelines.show.subtitle', mode: pipeline.mode),
                  class: 'text-muted')
  end

  def pipeline_owner(pipeline)
    content_tag(:div,
                I18n.t('patients.pipelines.show.owner', owner: pipeline.owner_name),
                class: 'label label-primary owner-label')
  end

  private

  def pipeline_icon(pipeline)
    if pipeline.automatic?
      finished = pipeline.computations.not_finished.count.zero?
      finished ? icon('sun-o') : icon('sun-o', class: 'fa-spin')
    else
      icon('cutlery')
    end
  end
end
