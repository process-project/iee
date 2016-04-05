class ResourcePolicy
  def initialize(user, resource)
    @user = user
    @resource = resource
  end

  def permit?(action_name)
    permissions(action_name).count > 0
  end

  private

  attr_reader :user, :resource

  def permissions(action_name)
    Permission.joins(:action).
      includes(group: :user_groups).references(group: :user_groups).
      where("permissions.user_id = :id OR user_groups.user_id = :id", id: user.id).
      where(resource_id: resource.id).
      where("actions.name = :name OR actions.name = 'manage'", name: action_name)
  end
end
