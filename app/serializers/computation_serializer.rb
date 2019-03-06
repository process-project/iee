# frozen_string_literal: true

class ComputationSerializer
  include FastJsonapi::ObjectSerializer
  include ComputationsHelper

  attributes :status, :error_message, :exit_code, :pipeline_step, :revision, :tag_or_branch

  attribute :required_files do |computation|
    computation.step.required_files unless computation.runnable?
  end
end
