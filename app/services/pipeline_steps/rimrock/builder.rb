# frozen_string_literal: true

module PipelineSteps
  module Rimrock
    class Builder
      def initialize(pipeline, name, params = {})
        @pipeline = pipeline
        @name = name
        @tag_or_branch = params[:tag_or_branch]
        @params = params
      end

      def call
        RimrockComputation.create!(
            pipeline: @pipeline,
            user: @pipeline.user,
            tag_or_branch: @tag_or_branch,
            pipeline_step: @name
        )
      end




      # def initialize(pipeline, name, params = {})
      #   @pipeline = pipeline
      #   @name = name
      #   @tag_or_branch = params[:tag_or_branch]
      # end
      #
      # def call
      #   RimrockComputation.create!(
      #     pipeline: @pipeline,
      #     user: @pipeline.user,
      #     tag_or_branch: @tag_or_branch,
      #     pipeline_step: @name
      #   )
      # end
    end
  end
end
