# frozen_string_literal: true
module ServicesHelper
  def pill_list(collection)
    content_tag(:ul, class: 'list-inline') do
      (collection || []).map do |item|
        concat(
          content_tag(
            :li,
            content_tag(:span, item.name, class: %w(label label-info label-xs))
          )
        )
      end
    end
  end
end
