# frozen_string_literal: true

class ChangeComputationStatusDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :computations, :status, from: 'new', to: 'created'
  end
end
