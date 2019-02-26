class CreateSingularityScriptBlueprints < ActiveRecord::Migration[5.1]
  def change
    create_table :singularity_script_blueprints do |t|
      t.string :container_name
      t.string :tag
      t.string :availble_options
      t.string :script_blueprint

      t.timestamps
    end
  end
end
