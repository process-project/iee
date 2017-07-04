# frozen_string_literal: true

class AddWorkingFileNameToComputations < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :working_file_name, :string
  end
end
