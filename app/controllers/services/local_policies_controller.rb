# frozen_string_literal: true

module Services
  class LocalPoliciesController < Services::PoliciesController
    def resource_type
      :local
    end

    def resource_path(service, resource)
      service_local_policy_path(service, resource)
    end

    def resources_path(service)
      service_local_policies_path(service)
    end
  end
end
