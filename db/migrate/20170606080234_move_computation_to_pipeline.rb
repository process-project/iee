# frozen_string_literal: true
class MoveComputationToPipeline < ActiveRecord::Migration[5.0]
  def change
    reversible do |direction|
      direction.up { execute('DELETE FROM computations') }
    end

    remove_reference :computations, :patient, index: true, foreign_key: true
    add_reference :computations, :pipeline, index: true, foreign_key: true
  end
end
