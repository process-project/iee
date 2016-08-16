# frozen_string_literal: true
class ResourcePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.joins(access_policies: [:access_method, :user]).
        where(access_methods: { name: 'manage' }).
        where(users: { id: user.id })
    end
  end

  def permit?(access_method_name)
    access_policies(access_method_name).count.positive?
  end

  def permitted_attributes
    if user.owns_resource?(record) || record.new_record?
      [:name, :path, :service_id]
    else
      []
    end
  end

  def destroy?
    user.owns_resource?(record)
  end

  private

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
