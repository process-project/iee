# frozen_string_literal: true
module Policies
  class BasePoliciesService
    def initialize(service)
      @service = service
    end

    protected

    def safely_create_access_policy(user, group, access_methods, resource, global = false)
      access_methods.each do |access_method_name|
        access_method = get_access_method(access_method_name, global)
        AccessPolicy.find_or_create_by(
          user: user,
          group: group,
          access_method: access_method,
          resource: resource
        )
      end
    end

    def merge_user_managers(user_emails, resource)
      user_emails.each do |email|
        safely_create_access_policy(User.find_by(email: email), nil, ['manage'], resource,
                                    true)
      end
    end

    def merge_group_managers(group_names, resource)
      group_names.each do |group_name|
        safely_create_access_policy(nil, Group.find_by(name: group_name), ['manage'], resource,
                                    true)
      end
    end

    def get_access_method(access_method_name, global)
      if global
        AccessMethod.find_by(name: access_method_name.downcase)
      else
        AccessMethod.find_by(name: access_method_name.downcase, service: @service)
      end
    end
  end
end
