module HamlHelper
  def form_input_class(input_name, subject)
    if subject.errors[input_name].present?
      "form-control parsley-error"
    else
      "form-control"
    end
  end
  
  def show_field_errors(input_name, subject)
    if subject.errors[input_name].present?
      haml_tag :ul, :class => "parsley-errors-list filled" do
        subject.errors[input_name].each do |error|
          haml_tag :li, error, :class => "parsley-required"
        end
      end
    end
  end
end