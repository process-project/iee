class ChangeParameterValuesTypeToJson < ActiveRecord::Migration[5.1]
  def up
    result = execute "SELECT id, parameter_values FROM computations WHERE parameter_values IS NOT null" 

    result.each do |row|
      id = row['id']
      converted_value = "'" + eval(row['parameter_values']).stringify_keys.to_json + "'"
      execute "UPDATE computations SET parameter_values = #{converted_value} WHERE id = #{id}"
    end

    change_column :computations, :parameter_values, 'json USING CAST(parameter_values AS json)'
  end

  def down
    result = execute "SELECT id, parameter_values FROM computations WHERE parameter_values IS NOT null" 

    change_column :computations, :parameter_values, :string

    result.each do |row|
      id = row['id']
      converted_value = "'" + eval(row['parameter_values']).symbolize_keys.to_s + "'"
      execute "UPDATE computations SET parameter_values = #{converted_value} WHERE id = #{id}"
    end
  end
end
