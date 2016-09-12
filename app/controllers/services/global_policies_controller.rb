# frozen_string_literal: true
module Services
  class GlobalPoliciesController < Services::PoliciesController
    def index
      @resources = @service.resources.where(resource_type: :global)
    end
  end
end
