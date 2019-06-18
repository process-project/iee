# frozen_string_literal: true

class StepParameter < ApplicationRecord
  belongs_to :singularity_script_blueprint

  def ==(other)
    other.instance_of?(self.class) and label == other.label
  end

  alias_method :eql?, :==
end
