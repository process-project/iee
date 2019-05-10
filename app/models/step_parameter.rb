# frozen_string_literal: true

class StepParameter < ApplicationRecord
	attr_reader :name, :label, :description, :rank, :datatype, :default
  has_and_belongs_to_many :singularity_script_blueprints

  def initialize(label, name, description, rank, datatype, default, values = [])
  	                      @label =  label,
                          @name = name,
                          @description = description,
                          @rank = rank,
                          @datatype = datatype,
                          @default = default,
                          @values =  values
  end

  def values
  	eval(read_attribute(:values))
  end
end
