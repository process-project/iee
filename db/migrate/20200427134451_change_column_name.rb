class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :singularity_script_blueprints, :hpc, :compute_site
  end
end
