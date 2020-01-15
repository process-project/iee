class ChangeStepParameterValuesType < ActiveRecord::Migration[5.1]
  def up
    change_column :step_parameters, :values, :string, array: true, default: [], using: "(string_to_array(values, ','))"
  end

  def down
    change_column :step_parameters, :values, :string
  end 
end
