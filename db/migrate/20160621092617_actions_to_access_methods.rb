class ActionsToAccessMethods < ActiveRecord::Migration[4.2]
  def change
    rename_table :actions, :access_methods
    rename_column :access_policies, :action_id, :access_method_id
  end
end
