# frozen_string_literal: true

module PipelineSteps
  module Cloudify
    class Runner < PipelineSteps::RunnerBase
      def initialize(computation, options = {})
        super(computation, options)
      end

      protected

      def pre_internal_run
        # Nothing yet
      end

      def internal_run
        Rails.logger.debug("Performing StartJob with params: #{computation.inspect}")
        ::Cloudify::StartJob.perform_later(computation) if computation.valid?
      end
    end
  end
end
