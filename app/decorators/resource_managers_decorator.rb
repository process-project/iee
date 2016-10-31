# frozen_string_literal: true
class ResourceManagersDecorator
  attr_accessor :resource, :resource_manager

  def initialize(resource, resource_manager)
    @resource = resource
    @resource_manager = resource_manager
  end

  def manager_users
    @manager_users ||= init_manager_users
  end

  def manager_groups
    @manager_groups ||= init_manager_groups
  end

  def users
    @users ||= User.approved
  end

  def groups
    @groups ||= GroupPolicy::Scope.new(@user, Group.all).resolve
  end

  private

  def init_manager_users
    resource.resource_managers.where(group_id: nil).includes(:user)
  end

  def init_manager_groups
    resource.resource_managers.where(user_id: nil).includes(:group)
  end
end
