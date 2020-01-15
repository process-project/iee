class DropBlueprintsStepParametersJoinTable < ActiveRecord::Migration[5.1]
  def change
    drop_join_table :singularity_script_blueprints, :step_parameters
  end
end
