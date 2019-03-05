# frozen_string_literal: true

module Segmentation
  class Abort
    def initialize(computation, updater, options = {})
      @computation = computation
      @segmentation = options.fetch(:segmentation) { Webdav::Segmentation.new }
      @updater = updater
      @msg = options.fetch(:msg, 'Job aborted')
    end

    def call
      return unless @computation.active?

      @segmentation.delete(Webdav::Segmentation.input_path(@computation))
      @computation.update(status: :aborted, error_message: @msg)
      @updater.new(@computation).call
    end
  end
end
