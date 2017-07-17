# frozen_string_literal: true

class AddInputPathToComputations < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :input_path, :string
  end
end
