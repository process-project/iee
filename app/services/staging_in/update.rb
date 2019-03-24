# frozen_string_literal: true

module StagingIn
  class Update
    def initialize(computation, options = {})
      @computation = computation
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
    end

    def call
      return if @computation.nil?
      @on_finish_callback&.new(@computation)&.call
      @updater&.new(@computation)&.call
    end
  end
end
