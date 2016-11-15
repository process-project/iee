# frozen_string_literal: true
module Resources
  class ResourceManagersController < Resources::ResourceRelationsController
    protected

    def build_related_object
      attrs = permitted_attributes(ResourceManager)
      attrs[:group_id] = nil if attrs[:group_id].blank?
      attrs[:user_id] = nil if attrs[:user_id].blank?

      @resource.resource_managers.find_or_initialize_by(attrs)
    end

    def find_related_object
      ResourceManager.find(params[:id])
    end

    def access_policy
      AccessPolicy.new
    end

    def resource_manager
      @related_object
    end
  end
end
