class RenameTagToContainerTag < ActiveRecord::Migration[5.1]
  def change
  	rename_column :singularity_script_blueprints, :tag, :container_tag
  end
end
