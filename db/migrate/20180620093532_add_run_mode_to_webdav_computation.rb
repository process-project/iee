class AddRunModeToWebdavComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :run_mode, :string, default: nil
  end
end
