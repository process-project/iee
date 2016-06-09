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
    Permission.joins(:action).
      includes(group: :user_groups).references(group: :user_groups).
      where("permissions.user_id = :id OR user_groups.user_id = :id", id: user.id).
      where(resource_id: record.id).
      where("LOWER(actions.name) = :name", name: action_name.downcase)
  end
end
