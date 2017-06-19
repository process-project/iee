# frozen_string_literal: true
module Policies
  class BasePoliciesService
    def initialize(service)
      @service = service
    end

    protected

    def safely_create_access_policy(user, group, access_methods, resource)
      access_methods.each do |access_method_name|
        AccessPolicy.find_or_create_by(
          user: user,
          group: group,
          access_method: access_method_for_name(access_method_name),
          resource: resource
        )
      end
    end

    def merge_user_managers(user_emails, resource)
      user_emails.each do |email|
        resource.resource_managers.
          find_or_create_by(user: User.find_by(email: email))
      end
    end

    def merge_group_managers(group_names, resource)
      group_names.each do |group_name|
        resource.resource_managers.
          find_or_create_by(group: Group.find_by(name: group_name))
      end
    end

    def access_method_for_name(access_method_name)
      AccessMethod.find_by(name: access_method_name.downcase, service: @service)
    end

    def find_subresources(pretty_path)
      @service.resources.where('path like :prefix', prefix: "#{PathService.to_path(pretty_path)}%")
    end

    def copy_managers(source_resource, target_resource)
      source_resource.resource_managers.each do |manager|
        target_resource.resource_managers << manager.dup
      end
    end

    def copy_policies(source_resource, target_resource)
      source_resource.access_policies.each do |access_policy|
        target_resource.access_policies << access_policy.dup
      end
    end

    def sub_path(root_path, sub_path)
      sub_path[root_path.length..-1]
    end
  end
end
