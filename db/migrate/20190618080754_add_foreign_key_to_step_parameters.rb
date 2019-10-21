class AddForeignKeyToStepParameters < ActiveRecord::Migration[5.1]
  def change
    add_column :step_parameters, :singularity_script_blueprint_id, :integer, null: false
    add_foreign_key :step_parameters, :singularity_script_blueprints
  end
end
