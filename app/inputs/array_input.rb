# frozen_string_literal: false
class ArrayInput < SimpleForm::Inputs::StringInput
  include ActionView::Helpers::JavaScriptHelper

  def input(_wrapper_options = nil)
    input_html_options[:type] ||= input_type

    a = gen_fields
    oid = "add_#{attribute_name}"
    a << javascript_tag(gen_script(oid))
    a << content_tag(:a, 'Add', href: "javascript:#{oid}()", id: oid)
    safe_join(a)
  end

  def input_type
    :text
  end

  private

  def gen_script(oid)
    script = "ni=0;function #{oid}() { "
    script << "$('a##{oid}').before('<input class=\"string optional form-control\" "
    script << 'error_html="parsley-error" type="text" style="margin-bottom: 5px" '
    script << "name=\"#{object_name}[#{attribute_name}][]\" "
    script << "id=\"#{attribute_name}_n'+ni+'\">'); ni = ni+1 }"
  end

  def gen_fields
    Array(object.public_send(attribute_name)).map.with_index do |array_el, fid|
      next_field array_el, fid
    end
  end

  def next_field(ae, fid)
    @builder.text_field(nil, input_html_options.merge(value: ae,
                                                      id: "#{attribute_name}_#{fid}",
                                                      class: 'string optional form-control',
                                                      style: 'margin-bottom: 5px',
                                                      error_html: 'parsley-error',
                                                      name: "#{object_name}[#{attribute_name}][]"))
  end
end
