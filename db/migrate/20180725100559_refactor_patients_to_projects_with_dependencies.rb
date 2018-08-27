class RefactorPatientsToProjectsWithDependencies < ActiveRecord::Migration[5.1]
  def change
    # Removing patients dependencies
    remove_reference :data_files, :patient, index: true, foreign_key: true
    remove_reference :pipelines, :patient, index: true

    # Refactoring patients to projects
    remove_index :patients, :case_number
    rename_column :patients, :case_number, :project_name
    rename_table :patients, :projects
    add_index :projects, :project_name

    # Restoring dependencies for projects
    add_reference :data_files, :project, foreign_key: {to_table: :projects}, 
                  index: {name: 'index_data_files_on_project_id'}
    add_reference :pipelines, :project, index: {name: 'index_pipelines_on_project_id'}
    add_index :pipelines, [:project_id, :iid], unique: true, name: 'index_pipelines_on_project_id_and_iid'
  end
end
