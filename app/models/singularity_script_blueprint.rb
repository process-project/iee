# frozen_string_literal: true

class SingularityScriptBlueprint < ApplicationRecord
	has_and_belongs_to_many :step_parameters
end
