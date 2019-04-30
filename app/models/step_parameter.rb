# frozen_string_literal: true

class StepParameter < ApplicationRecord
  has_and_belongs_to_many :singularity_script_blueprints
end
