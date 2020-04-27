class AddComputeSiteToSingularityScriptBlueprint < ActiveRecord::Migration[5.1]
  def change
    add_reference :singularity_script_blueprints, :compute_site,
                  null: true
  end
end
