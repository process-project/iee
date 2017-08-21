# frozen_string_literal: true

class AddTagOrBranchToComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :tag_or_branch, :string
  end
end
