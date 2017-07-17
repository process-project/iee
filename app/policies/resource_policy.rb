# frozen_string_literal: true

class ResourcePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.joins(:resource_managers).
        where(resource_managers: { user_id: user.id })
    end
  end

  def self.user_owns_resources?(user, resource_paths)
    Resource.where(path: resource_paths).map do |resource|
      ResourcePolicy.new(user, resource).owns_resource?
    end.reduce(:&)
  end

  def permit?(access_method_name)
    user.approved? && access_policies(access_method_name).count.positive?
  end

  def permitted_attributes
    [:name, :pretty_path]
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
    owns_service? || record.local? && owns_local_resource?
  end

  def copy_move?
    owns_resource?
  end

  private

  def owns_local_resource?
    record.resource_managers.where(user_id: user.id).exists?
  end

  def owns_service?
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
