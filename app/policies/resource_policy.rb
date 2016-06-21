class ResourcePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::ApplicationScope
    def resolve
      scope.joins(access_policies: [:access_method, :user])
        .where(access_methods: {name: "manage"})
        .where(users: {id: user.id})
    end
  end

  def permit?(access_method_name)
    access_policies(access_method_name).count > 0
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
    AccessPolicy.joins(:access_method).
      includes(group: :user_groups).references(group: :user_groups).
      where("access_policies.user_id = :id OR user_groups.user_id = :id", id: user.id).
      where(resource_id: record.id).
      where("LOWER(access_methods.name) = :name", name: access_method_name.downcase)
  end
end
