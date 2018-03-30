class AddDeploymentToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :deployment, :string, default: 'cluster', null: false
  end
end
