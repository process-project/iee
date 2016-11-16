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
      if only_paths_given?
        Resource.where(path: @resource_paths).destroy_all
      else
        query = AccessPolicy.joins(:resource).where(resources: { path: @resource_paths })
        query = complete_where_clauses(query)
        query.destroy_all
      end
    end

    private

    def complete_where_clauses(query)
      unless @access_method_names.empty?
        query = query.joins(:access_method).
                where(access_methods: { name: @access_method_names })
      end

      unless @user_emails.empty? && @group_names.empty?
        query = query.left_outer_joins(:user).left_outer_joins(:group).
                where('users.email = ? OR groups.name = ?', @user_emails, @group_names)
      end

      query
    end

    def only_paths_given?
      @user_emails.empty? && @group_names.empty? && @access_method_names.empty?
    end
  end
end
