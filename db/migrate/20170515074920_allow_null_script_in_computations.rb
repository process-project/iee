# frozen_string_literal: true

class AllowNullScriptInComputations < ActiveRecord::Migration[5.0]
  def change
    change_column_null :computations, :script, true
  end
end
