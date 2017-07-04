# frozen_string_literal: true

class AddApprovedToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :approved, :boolean, default: false, null: false
  end
end
