class ChangeParameterValuesTypeToJson < ActiveRecord::Migration[5.1]
  def change
    change_column :computations, :parameter_values, 'json USING CAST(parameter_values AS json)'
  end
end
