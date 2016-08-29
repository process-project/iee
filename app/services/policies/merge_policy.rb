# frozen_string_literal: true
module Policies
  class MergePolicy
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
          merge_user_managers(@json_body['managers']['users'])
        end

        if @json_body['managers']['groups']
          merge_group_managers(@json_body['managers']['groups'])
        end
      end
    end

    def merge_permissions
      if @json_body['permissions']
        @json_body['permissions'].each do |permission|
          safely_create_access_policy(
            User.find_by(email: permission['entity_name']),
            Group.find_by(name: permission['entity_name']),
            permission['access_methods']
          )
        end
      end
    end

    def safely_create_access_policy(user, group, access_methods)
      access_methods.each do |access_method|
        AccessPolicy.find_or_create_by(
          user: user,
          group: group,
          access_method: AccessMethod.find_by(name: access_method.downcase),
          resource: @resource
        )
      end
    end

    def merge_user_managers(user_emails)
      user_emails.each do |email|
        safely_create_access_policy(User.find_by(email: email), nil, ['manage'])
      end
    end

    def merge_group_managers(group_names)
      group_names.each do |group_name|
        safely_create_access_policy(nil, Group.find_by(name: group_name), ['manage'])
      end
    end
  end
end
