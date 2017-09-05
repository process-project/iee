# frozen_string_literal: true

class AddModeToPipeline < ActiveRecord::Migration[5.1]
  def change
    add_column :pipelines, :mode, :integer, default: 0, null: false
  end
end
