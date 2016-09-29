# frozen_string_literal: true
AdminPolicy = Struct.new(:user, :admin) do
  def manage_users?
    user&.admin? || user&.supervisor?
  end
end
