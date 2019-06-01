# frozen_string_literal: true

FactoryBot.define do
  factory :singularity_script_blueprint do
    container_name "placeholder workaround hardcode"
    container_tag "latest"
    hpc "Prometheus"
    script_blueprint "parameter1 %<label1>s parameter2 %<label2>s parameter3 %<label3>s"

    step_parameters [
      StepParameter.new('label1', 'name', 'desc', 0, 'string', 'default_value'),
      StepParameter.new('label2', 'name', 'desc', 0, 'integer', 1),
      StepParameter.new('label3', 'name', 'desc', 0, 'multi', 'first_value', %w[first_value second_value third_value]),
    ]
  end
end