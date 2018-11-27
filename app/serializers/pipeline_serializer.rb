# frozen_string_literal: true

class PipelineSerializer
  include FastJsonapi::ObjectSerializer
  set_id :iid
  attributes :iid, :name, :flow, :inputs_dir, :outputs_dir
  has_many :computations
end
