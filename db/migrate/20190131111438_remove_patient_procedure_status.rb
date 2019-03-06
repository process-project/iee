# frozen_string_literal: true

class RemovePatientProcedureStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :patients, :procedure_status, null: false, index: true, default: 0
  end
end
