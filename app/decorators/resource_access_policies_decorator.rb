# frozen_string_literal: true
class ResourceAccessPoliciesDecorator
  attr_accessor :resource, :access_policy, :service

  def initialize(resource, access_policy)
    @resource = resource
    @access_policy = access_policy
    @service = resource.service
  end

  def group_access_policies
    @group_access_policies ||= init_group_access_policies
  end

  def user_access_policies
    @user_access_policies ||= init_user_access_policies
  end

  def users
    @users ||= User.approved
  end

  def groups
    @groups ||= Group.all
  end

  def access_methods
    @access_methods ||= (AccessMethod.global + @service.access_methods)
  end

  private

  def init_group_access_policies
    group(query: { user_id: nil }, includes: [:group, :access_method]) do |ap|
      ap.group.name
    end
  end

  def init_user_access_policies
    group(query: { group_id: nil }, includes: [:user, :access_method]) do |ap|
      ap.user.email
    end
  end

  def group(query:, includes:)
    resource.access_policies.
      where(query).
      includes(includes).
      each_with_object(array_initialized_hsh) do |ap, hsh|
        hsh[yield(ap)] << ap
      end
  end

  def array_initialized_hsh
    Hash.new { |h, k| h[k] = [] }
  end
end
