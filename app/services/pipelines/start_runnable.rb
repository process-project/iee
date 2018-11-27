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
        valid_proxy?(computation) &&
        configured?(computation)
    end

    def valid_proxy?(computation)
      !computation.rimrock? || @user_proxy.valid?
    end

    def configured?(computation)
      if computation.rimrock?
        computation.tag_or_branch.present?
      elsif computation.webdav?
        computation.run_mode.present?
      end
    end
  end
end
