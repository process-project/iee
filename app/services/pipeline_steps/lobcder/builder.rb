# frozen_string_literal: true

module PipelineSteps
  module Lobcder
    class Builder
      def initialize(pipeline, name, src_compute_site_name = nil, src_path = nil, dest_compute_site_name = nil,
                     dest_path = nil)
        @pipeline = pipeline
        @name = name
        @src_compute_site = ComputeSite.where(full_name: src_compute_site_name).first
        @src_path = src_path
        @dest_compute_site = ComputeSite.where(full_name: dest_compute_site_name).first
        @dest_path = dest_path
      end

      def call
        LobcderComputation.create!(pipeline: @pipeline,
                                   user: @pipeline.user,
                                   pipeline_step: @name,
                                   src_compute_site: @src_compute_site,
                                   input_path: @src_path,
                                   dest_compute_site: @dest_compute_site,
                                   output_path: @dest_path)
      end
    end
  end
end
