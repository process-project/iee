class AddTmpOutputFileToStagingInComputation < ActiveRecord::Migration[5.1]
  def change
    add_column :computations, :tmp_output_file, :string
  end
end
