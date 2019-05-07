class RenameUserParametersInComputations < ActiveRecord::Migration[5.1]
  def change
    rename_column :computations, :user_parameters, :parameter_values
  end
end
