class AddRevisionToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :revision, :string
  end
end
