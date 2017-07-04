# frozen_string_literal: true

class AddTypeToComputationsForSti < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :type, :string
  end
end
