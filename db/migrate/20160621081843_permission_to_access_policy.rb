class PermissionToAccessPolicy < ActiveRecord::Migration[4.2]
  def change
    rename_table :permissions, :access_policies
  end
end
