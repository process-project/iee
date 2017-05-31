# frozen_string_literal: true
require 'net/dav'

module Pipelines
  class Base < PatientWebdav
    def initialize(user, pipeline, options = {})
      super(user, options)
      @pipeline = pipeline
    end

    def call
      Pipeline.transaction { internal_call }
      @pipeline
    end
  end
end
