# frozen_string_literal: true
module Policies
  class RemovePolicies
    def initialize(resource_paths, user_emails, group_names, access_method_names)
      @resource_paths = resource_paths
      @user_emails = user_emails
      @group_names = group_names
      @access_method_names = access_method_names
    end

    def call
      query = AccessPolicy.where(resource: Resource.where(path: @resource_paths))
      query = complete_where_clauses(query)
      query.destroy_all

      remove_resources if only_paths_given?
    end

    private

    def complete_where_clauses(query)
      filter_manage_role(query)
      query = query.where(access_method: AccessMethod.where(name: @access_method_names)) unless
        @access_method_names.empty?
      query = query.where(user: User.where(email: @user_emails)) unless @user_emails.empty?
      query = query.where(group: Group.where(name: @group_names)) unless @group_names.empty?

      query
    end

    def remove_resources
      Resource.where(path: @resource_paths).destroy_all
    end

    def filter_manage_role(query)
      query.where.not(access_method: AccessMethod.where(name: 'manage')) if only_paths_given?
    end

    def only_paths_given?
      @user_emails.empty? && @group_names.empty? && @access_method_names.empty?
    end
  end
end
