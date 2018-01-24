# frozen_string_literal: true

class Step
  attr_reader :name

  def initialize(name, required_files = [])
    @name = name
    @required_files = required_files || []
  end

  def runnable_for?(pipeline)
    @required_files.map { |rf| pipeline.data_file(rf) }.all?
  end
end
