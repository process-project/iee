class AddUserParametersToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :user_parameters, :string
  end
end