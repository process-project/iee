# frozen_string_literal: true

module PipelineSteps
  module Scripted
    class Builder
      def initialize(pipeline, name, params = {})
        @pipeline = pipeline
        @name = name
        @deployment = params[:deployment]
        @tag_or_branch = params[:tag_or_branch]
      end

      def call
        ScriptedComputation.create!(
          pipeline: @pipeline,
          user: @pipeline.user,
          tag_or_branch: @tag_or_branch,
          pipeline_step: @name,
          deployment: @deployment
        )
      end
    end
  end
end
