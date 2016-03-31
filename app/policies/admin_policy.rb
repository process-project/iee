class AdminPolicy < Struct.new(:user, :admin)
  def manage_users?
    user && user.groups.where(name: 'supervisor').exists?
  end
end
