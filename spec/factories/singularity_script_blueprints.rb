# frozen_string_literal: true

FactoryBot.define do
  factory :singularity_script_blueprint do
    container_name 'placeholder workaround hardcode'
    container_tag 'latest'
    compute_site ComputeSite.where(name: :krk).first
    script_blueprint 'parameter1 %<label1>s parameter2 %<label2>s parameter3 %<label3>s'

    step_parameters do
      [
        StepParameter.new(
          label: 'label1',
          name: 'name',
          description: 'desc',
          rank: 0,
          datatype: 'string',
          default: 'default_value'
        ),
        StepParameter.new(
          label: 'label2',
          name: 'name',
          description: 'desc',
          rank: 0,
          datatype: 'integer',
          default: 1
        ),
        StepParameter.new(
          label: 'label3',
          name: 'name',
          description: 'desc',
          rank: 0,
          datatype: 'multi',
          default: 'first_value',
          values: %w[first_value second_value third_value]
        )
      ]
    end
  end
end
