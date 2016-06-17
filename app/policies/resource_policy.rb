class ResourcePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.joins(permissions: [:action, :user])
        .where(actions: {name: "manage"})
        .where(users: {id: user.id})
    end
  end

  def permit?(action_name)
    permissions(action_name).count > 0
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

  def permissions(action_name)
    groups_with_ancestors = UserGroupsWithAncestors.new(user).get
    group_ids = groups_with_ancestors.collect { |g| g.id }

    Permission.joins(:action).
      includes(:group).references(:group).
      where("permissions.user_id = :user_id OR groups.id IN (:group_ids)", user_id: user.id, group_ids: group_ids).
      where(resource_id: record.id).
      where("LOWER(actions.name) = :name", name: action_name.downcase)
  end
end
