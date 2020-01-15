class AddServiceNameToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :deployment_name, :string
    add_column :computations, :workflow_id, :string
    add_column :computations, :cloudify_status, :string, default: 'not_started'
  end
end