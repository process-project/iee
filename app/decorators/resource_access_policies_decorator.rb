# frozen_string_literal: true
class ResourceAccessPoliciesDecorator
  attr_accessor :resource, :access_policy, :service

  def initialize(resource, access_policy, service = nil)
    @resource = resource
    @access_policy = access_policy
    @service = service || resource.service
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
    @access_methods ||= AccessMethod.all
  end

  private

  def init_group_access_policies
    Group.joins(access_policies: :resource).
      includes(access_policies: :access_method).
      where(resources: { id: resource.id }).
      each_with_object({}) do |group, hsh|
        hsh[group.name] = group.access_policies.
                          where(resource_id: @resource.id)
      end
  end

  def init_user_access_policies
    User.joins(access_policies: :resource).
      includes(access_policies: :access_method).
      where(resources: { id: resource.id }).
      each_with_object({}) do |user, hsh|
        hsh[user.email] = user.access_policies.
                          where(resource_id: @resource.id)
      end
  end
end
