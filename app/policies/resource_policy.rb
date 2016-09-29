# frozen_string_literal: true
class ResourcePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.joins(access_policies: [:access_method, :user]).
        where(access_methods: { name: 'manage' }).
        where(users: { id: user.id })
    end
  end

  def self.user_owns_resources?(user, resource_paths)
    Resource.where(path: resource_paths).map do |resource|
      ResourcePolicy.new(user, resource).owns_resource?
    end.reduce(:&)
  end

  def permit?(access_method_name)
    access_policies(access_method_name).count.positive?
  end

  def permitted_attributes
    [:name, :path]
  end

  def new?
    user.admin? || owns_resource?
  end

  def create?
    user.admin? || owns_resource?
  end

  def show?
    user.admin? || owns_resource?
  end

  def edit?
    user.admin? || owns_resource?
  end

  def update?
    user.admin? || owns_resource?
  end

  def destroy?
    user.admin? || owns_resource?
  end

  def owns_resource?
    if record.global?
      owns_global_resource?
    else
      owns_local_resource?
    end
  end

  private

  def owns_local_resource?
    record.access_policies.joins(:access_method).
      where(user_id: user.id, access_methods: { name: 'manage' }).exists?
  end

  def owns_global_resource?
    record.service.users.include?(user)
  end

  def access_policies(access_method_name)
    groups_with_ancestors = UserGroupsWithAncestors.new(user).get
    group_ids = groups_with_ancestors.collect(&:id)

    AccessPolicy.joins(:access_method).
      includes(:group).references(:group).
      where(
        '(access_policies.user_id = :user_id OR groups.id IN (:group_ids))'\
        ' AND resource_id = :resource_id',
        user_id: user.id, group_ids: group_ids, resource_id: record.id
      ).where('LOWER(access_methods.name) = :name', name: access_method_name.downcase)
  end
end
