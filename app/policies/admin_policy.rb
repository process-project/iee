# frozen_string_literal: true
AdminPolicy = Struct.new(:user, :admin) do
  def manage_users?
    user && user.groups.where(name: 'supervisor').exists?
  end
end
