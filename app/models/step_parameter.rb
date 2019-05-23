# frozen_string_literal: true

class StepParameter < ApplicationRecord
  has_and_belongs_to_many :singularity_script_blueprints

  def initialize(label, name, description, rank, datatype, default, values = [])
  	super(label: label,
  				name: name,
  				description: description,
  				rank: rank,
  				datatype: datatype,
  				default: default,
  				values: values.to_s)
    @label =  label,
    @name = name,
    @description = description,
    @rank = rank,
    @datatype = datatype,
    @default = default,
    @values = values.to_s
  end

  def values
  	eval(read_attribute(:values))
  end

  # def ==(o)
  #   @label == o.label and @name == o.name and @description == o.description and @datatype == o.datatype and @default == o.default and @values == o.values
  # end

  # def values=(values)
  # 	@values = values.to_s
  # end
end
