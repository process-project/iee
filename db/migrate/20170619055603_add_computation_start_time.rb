# frozen_string_literal: true
class AddComputationStartTime < ActiveRecord::Migration[5.0]
  def change
    add_column :computations, :started_at, :datetime
  end
end
