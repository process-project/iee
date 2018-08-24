class ExciseProcedureStatusFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_index :projects, column: :procedure_status
    remove_column :projects, :procedure_status, :integer
  end
end
