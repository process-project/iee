# frozen_string_literal: true

module Pipelines
  class Affected
    def initialize(data_files)
      @data_files = data_files
    end

    def call
      Pipeline.
        where(patient_id: patients_ids).
        or(Pipeline.where(id: pipelines_ids)).
        uniq
    end

    private

    def patients_ids
      @data_files.
        reject { |df| df.input_of_id || df.output_of_id }.
        map(&:patient_id)
    end

    def pipelines_ids
      @data_files.
        map { |df| df.input_of_id || df.output_of_id }.
        reject(&:blank?)
    end
  end
end
