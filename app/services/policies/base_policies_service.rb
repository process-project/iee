# frozen_string_literal: true
module Policies
  class BasePoliciesService
    protected

    def safely_create_access_policy(user, group, access_methods, resource)
      access_methods.each do |access_method|
        AccessPolicy.find_or_create_by(
          user: user,
          group: group,
          access_method: AccessMethod.find_by(name: access_method.downcase),
          resource: resource
        )
      end
    end

    def merge_user_managers(user_emails, resource)
      user_emails.each do |email|
        safely_create_access_policy(User.find_by(email: email), nil, ['manage'], resource)
      end
    end

    def merge_group_managers(group_names, resource)
      group_names.each do |group_name|
        safely_create_access_policy(nil, Group.find_by(name: group_name), ['manage'], resource)
      end
    end
  end
end
