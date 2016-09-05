# frozen_string_literal: false
class ArrayInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::JavaScriptHelper

  def input(_wrapper_options = nil)
    input_html_options[:type] ||= input_type

    a = gen_fields
    oid = SecureRandom.hex(4)
    script = "ni=0;function addAI#{oid}() { "
    script << "$('a#add').before('<input class=\"string optional form-control\" "
    script << "error_html=\"parsley-error\" type=\"text\" style=\"margin-bottom: 5px\" "
    script << "name=\"service[uri_aliases][]\" id=\"service_'+ni+'\">'); ni = ni+1 }"
    a << javascript_tag(script)
    a << content_tag(:a, 'Add', href: "javascript:addAI#{oid}()", id: 'add')
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
