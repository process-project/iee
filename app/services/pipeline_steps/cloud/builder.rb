# frozen_string_literal: true

module PipelineSteps
  module Cloud
    class Builder
      def initialize(pipeline, atmosphere_url, name, params = {})
        @pipeline = pipeline
        @atmosphere_url = atmosphere_url
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
