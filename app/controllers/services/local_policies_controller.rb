# frozen_string_literal: true
module Services
  class LocalPoliciesController < Services::PoliciesController
    def index
      @resources = @service.resources.where(resource_type: :local)
    end
  end
end
