# frozen_string_literal: true

module Pipelines
  class StartRunnable
    def initialize(pipeline)
      @pipeline = pipeline
      @user_proxy = Proxy.new(pipeline.user)
    end

    def call
      internal_call if @pipeline.automatic?
    end

    private

    def internal_call
      @pipeline.computations.created.each { |c| c.run if runnable?(c) }
    end

    def runnable?(computation)
      computation.runnable? &&
        (
          (computation.rimrock? && @user_proxy.valid?) ||
          (computation.cloud? && computation.tag_or_branch.present?) ||
          computation.webdav?
        )
    end
  end
end
