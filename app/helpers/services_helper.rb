# frozen_string_literal: true

module ServicesHelper
  def pill_list(collection)
    content_tag(:ul, class: 'list-inline') do
      (collection || []).map do |item|
        name = block_given? ? yield(item) : item.name
        concat(
          content_tag(
            :li, content_tag(:span, name, class: %w[label label-info label-xs])
          )
        )
      end
    end
  end

  def global_access_methods_hint
    global_access_methods = AccessMethod.global.pluck(:name)
    return if global_access_methods.blank?
    I18n.t('simple_form.hints.service.access_methods',
           globals: global_access_methods.join(', '))
  end
end
