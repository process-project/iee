class ChangeStepParameterValuesType < ActiveRecord::Migration[5.1]
  def change
    change_column :step_parameters, :values, :string, array: true, default: [], using: "(string_to_array(values, ','))"
  end
end
