module HamlHelper
  def form_input_class(resource, input_name)
    if resource.errors[input_name].present?
      "form-control parsley-error"
    else
      "form-control"
    end
  end
  
  def show_field_errors(resource, input_name)
    if resource.errors[input_name].present?
      haml_tag :ul, :class => "parsley-errors-list filled" do
        resource.errors[input_name].each do |error|
          haml_tag :li, error, :class => "parsley-required"
        end
      end
    end
  end
end