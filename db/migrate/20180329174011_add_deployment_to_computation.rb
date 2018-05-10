class AddDeploymentToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :deployment, :string, default: 'cluster', null: true
    add_column :computations, :appliance_id, :string, null: true
  end
end
