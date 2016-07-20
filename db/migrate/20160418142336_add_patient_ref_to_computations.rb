class AddPatientRefToComputations < ActiveRecord::Migration[4.2]
  def change
    add_reference :computations, :patient, index: true, foreign_key: true
  end
end
