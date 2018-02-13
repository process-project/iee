# frozen_string_literal: true

module PipelineSteps
  module Cloud
    class Builder
      def initialize(pipeline, name, params = {})
        @pipeline = pipeline
        @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
        @name = name
        @tag_or_branch = params[:tag_or_branch]
      end

      def call
        CloudComputation.create(
          pipeline: @pipeline,
          user: @pipeline.user,
          tag_or_branch: @tag_or_branch,
          pipeline_step: @name
        )
      end
    end
  end
end
