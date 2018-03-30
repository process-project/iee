# frozen_string_literal: true

class Step
  attr_reader :name, :required_files, :deployment

  def initialize(name, required_files = [], deployment = 'cluster')
    @name = name
    @required_files = required_files || []
    @deployment = deployment
  end

  def input_present_for?(pipeline)
    @required_files.map { |rf| pipeline.data_file(rf) }.all?
  end
end
