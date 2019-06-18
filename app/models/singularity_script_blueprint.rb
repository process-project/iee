# frozen_string_literal: true

class SingularityScriptBlueprint < ApplicationRecord
  has_many :step_parameters, dependent: :destroy
end
