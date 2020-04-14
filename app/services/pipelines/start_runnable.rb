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
      @pipeline.computations.created.each do |c|
        if runnable?(c)
          ActivityLogWriter.write_message(@pipeline.user, @pipeline, c, 'launching_computation')
          c.run
        end
      end
    end

    def runnable?(computation)
      computation.runnable? &&
        (!computation.rimrock? || @user_proxy.valid?)
    end
  end
end
