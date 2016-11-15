# frozen_string_literal: true
module Resources
  class AccessPoliciesController < Resources::ResourceRelationsController
    protected

    def build_related_object
      @resource.access_policies.build(permitted_attributes(AccessPolicy))
    end

    def find_related_object
      AccessPolicy.find(params[:id])
    end

    def access_policy
      @related_object
    end

    def resource_manager
      ResourceManager.new
    end
  end
end
