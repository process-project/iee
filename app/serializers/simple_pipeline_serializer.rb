# frozen_string_literal: true

class SimplePipelineSerializer
  include FastJsonapi::ObjectSerializer
  set_id :iid
  attributes :iid, :name, :flow
  set_type 'pipeline'
end
