class RemoveAvailableOptionsFromSingularityScriptBlueprints < ActiveRecord::Migration[5.1]
  def change
  	remove_column :singularity_script_blueprints, :available_options
  end
end
