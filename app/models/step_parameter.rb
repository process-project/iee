# frozen_string_literal: true

class StepParameter < ApplicationRecord
  belongs_to :singularity_script_blueprint

  def ==(other)
    other.instance_of?(self.class) && label == other.label
  end

  alias eql? ==
end
