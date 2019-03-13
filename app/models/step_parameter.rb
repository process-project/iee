# frozen_string_literal: true

class StepParameter
  attr_reader :name, :label, :description, :rank, :datatype, :default, :values

  def initialize(label, name, description, rank, datatype, default, values = [])
    @label = label
    @name = name
    @description = description
    @rank = rank
    @datatype = datatype
    @default = default
    @values = values
  end
end
