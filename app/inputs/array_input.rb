# frozen_string_literal: true
class ArrayInput < SimpleForm::Inputs::StringInput
  def input(_wrapper_options = nil)
    input_html_options[:type] ||= input_type

    a = gen_fields
    a << content_tag(:a, 'Add', href: 'javascript:', id: 'add')
    safe_join(a)
  end

  def input_type
    :text
  end

  private

  def gen_fields
    Array(object.public_send(attribute_name)).map do |array_el|
      next_field array_el
    end
  end

  def next_field(ae)
    @builder.text_field(nil, input_html_options.merge(value: ae,
                                                      class: 'string optional form-control',
                                                      style: 'margin-bottom: 5px',
                                                      error_html: 'parsley-error',
                                                      name: "#{object_name}[#{attribute_name}][]"))
  end
end
