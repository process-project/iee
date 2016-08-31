# frozen_string_literal: true
module Policies
  class MergePolicy < Policies::BasePoliciesService
    def initialize(json_body, resource)
      @json_body = json_body
      @resource = resource
    end

    def call
      merge_managers
      merge_permissions
    end

    private

    def merge_managers
      if @json_body['managers']
        if @json_body['managers']['users']
          merge_user_managers(@json_body['managers']['users'], @resource)
        end

        if @json_body['managers']['groups']
          merge_group_managers(@json_body['managers']['groups'], @resource)
        end
      end
    end

    def merge_permissions
      if @json_body['permissions']
        @json_body['permissions'].each do |permission|
          safely_create_access_policy(
            User.find_by(email: permission['entity_name']),
            Group.find_by(name: permission['entity_name']),
            permission['access_methods'],
            @resource
          )
        end
      end
    end
  end
end
