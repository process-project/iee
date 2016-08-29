# frozen_string_literal: true
module Policies
  class BuildPolicyResponse
    def initialize(resource_paths)
      @resource_paths = resource_paths
    end

    def call
      { policies: build_policies }
    end

    private

    def build_policies
      fetch_resources.map do |resource|
        { path: resource.path, managers: managers(resource), permissions: permissions(resource) }
      end
    end

    def fetch_resources
      @resource_paths.any? ? Resource.where(path: @resource_paths) : Resource.all
    end

    def managers(resource)
      policies = management_access_policies(resource)

      {
        users: policies.select(&:user).map { |policy| policy.user.email },
        groups: policies.select(&:group).map { |policy| policy.group.name }
      }
    end

    def permissions(resource)
      policies = non_management_access_policies(resource)
      user_methods = Hash.new { |h, k| h[k] = [] }
      group_methods = Hash.new { |h, k| h[k] = [] }
      process_policies(policies, user_methods, group_methods)

      build_user_permissions(user_methods) + build_group_permissions(group_methods)
    end

    def management_access_policies(resource)
      AccessPolicy.where(resource: resource, access_method: AccessMethod.where(name: 'manage'))
    end

    def non_management_access_policies(resource)
      AccessPolicy.where(resource: resource).
        where.not(access_method: AccessMethod.where(name: 'manage'))
    end

    def process_policies(policies, user_methods, group_methods)
      policies.each do |policy|
        if policy.user
          user_methods[policy.user.email] << policy.access_method.name
        else
          group_methods[policy.group.name] << policy.access_method.name
        end
      end
    end

    def build_user_permissions(user_methods)
      user_methods.map do |user, methods|
        { type: 'user_permission', entity_name:  user, access_methods: methods }
      end
    end

    def build_group_permissions(group_methods)
      group_methods.map do |group, methods|
        { type: 'group_permission', entity_name:  group, access_methods: methods }
      end
    end
  end
end
