# frozen_string_literal: true
module Policies
  class BuildPolicyResponse
    def initialize(resource_paths, service)
      @resource_paths = resource_paths
      @service = service
    end

    def call
      { policies: build_policies }
    end

    private

    def build_policies
      fetch_resources.map do |resource|
        {
          path: resource.pretty_path,
          managers: managers(resource),
          permissions: permissions(resource)
        }
      end
    end

    def fetch_resources
      resources = Resource.where(service: @service)
      @resource_paths.any? ? resources.where(path: @resource_paths) : resources
    end

    def managers(resource)
      policies = resource.resource_managers

      {
        users: policies.select(&:user).map { |policy| policy.user.email },
        groups: policies.select(&:group).map { |policy| policy.group.name }
      }
    end

    def permissions(resource)
      policies = access_policies(resource)
      user_methods, group_methods = process_policies(policies)
      build_user_permissions(user_methods) + build_group_permissions(group_methods)
    end

    def access_policies(resource)
      resource.access_policies.includes(:user, :group, :access_method)
    end

    def process_policies(policies)
      user_methods = policies_to_user_method_map(policies.select(&:user))
      group_methods = policies_to_group_method_map(policies.select(&:group))

      [user_methods, group_methods]
    end

    def build_user_permissions(user_methods)
      user_methods.map do |user, methods|
        { type: 'user_permission', entity_name: user, access_methods: methods }
      end
    end

    def build_group_permissions(group_methods)
      group_methods.map do |group, methods|
        { type: 'group_permission', entity_name: group, access_methods: methods }
      end
    end

    def policies_to_user_method_map(user_policies)
      user_methods = Hash.new { |h, k| h[k] = [] }

      user_policies.each do |policy|
        user_methods[policy.user.email] << policy.access_method.name
      end

      user_methods
    end

    def policies_to_group_method_map(group_policies)
      group_methods = Hash.new { |h, k| h[k] = [] }

      group_policies.each do |policy|
        group_methods[policy.group.name] << policy.access_method.name
      end

      group_methods
    end
  end
end
