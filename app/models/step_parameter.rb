# frozen_string_literal: true

class StepParameter < ApplicationRecord
  has_and_belongs_to_many :singularity_script_blueprints

  # rubocop:disable Metrics/MethodLength
  def initialize(label, name, description, rank, datatype, default, values = [])
    super(
      label: label,
      name: name,
      description: description,
      rank: rank,
      datatype: datatype,
      default: default,
      values: values.to_s
    )
    @label = label
    @name = name
    @description = description
    @rank = rank
    @datatype = datatype
    @default = default
    @values = values.to_s
  end
  # rubocop:enable Metrics/MethodLength

  def values
    eval(sel[:values])
  end
end
