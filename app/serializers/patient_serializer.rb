# frozen_string_literal: true

class PatientSerializer
  include FastJsonapi::ObjectSerializer
  set_id :case_number
  attributes :case_number
  has_many :pipelines, serializer: SimplePipelineSerializer
end
