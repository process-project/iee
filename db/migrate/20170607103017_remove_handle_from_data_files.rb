# frozen_string_literal: true

class RemoveHandleFromDataFiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :data_files, :handle
  end
end
