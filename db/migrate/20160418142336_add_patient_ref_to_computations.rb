class AddPatientRefToComputations < ActiveRecord::Migration
  def change
    add_reference :computations, :patient, index: true, foreign_key: true
  end
end
