# frozen_string_literal: true

class Step
  attr_reader :name, :required_files

  def initialize(name, required_files = [])
    @name = name
    @required_files = required_files || []
  end

  def input_present_for?(_pipeline)
    true
  end
end
