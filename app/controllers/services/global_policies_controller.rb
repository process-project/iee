# frozen_string_literal: true
module Services
  class GlobalPoliciesController < Services::PoliciesController
    private

    def resource_type
      :global
    end

    def resource_path(service, resource)
      service_global_policy_path(service, resource)
    end

    def resources_path(service)
      service_global_policies_path(service)
    end
  end
end
