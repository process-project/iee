# frozen_string_literal: true

module Policies
  class MergePolicy < Policies::BasePoliciesService
    def initialize(json_body, resource, service)
      super(service)
      @json_body = json_body
      @resource = resource
    end

    def call
      merge_managers
      merge_permissions
    end

    private

    def merge_managers
      return unless @json_body['managers']

      merge_user_managers(@json_body['managers']['users'] || [], @resource)
      merge_group_managers(@json_body['managers']['groups'] || [], @resource)
    end

    def merge_permissions
      (@json_body['permissions'] || []).each do |permission|
        safely_create_access_policy(User.find_by(email: permission['entity_name']),
                                    Group.find_by(name: permission['entity_name']),
                                    permission['access_methods'], @resource)
      end
    end
  end
end
