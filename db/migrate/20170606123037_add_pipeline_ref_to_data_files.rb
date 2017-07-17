# frozen_string_literal: true

class AddPipelineRefToDataFiles < ActiveRecord::Migration[5.0]
  def up
    add_reference :data_files, :pipeline, index: true, foreign_key: true, null: true
    execute('DELETE FROM data_files')
  end

  def down
    remove_reference :data_files, :pipeline
  end
end
