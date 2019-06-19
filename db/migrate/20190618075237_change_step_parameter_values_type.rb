class ChangeStepParameterValuesType < ActiveRecord::Migration[5.1]
  def up
    change_column :step_parameters, :values, :string, array: true, default: [], using: "(string_to_array(values, ','))"
  end

  def down
    change_column :step_parameters, :values, :string
    # result = execute "SELECT id, values FROM step_parameters WHERE values IS NOT null" 



    # result.each do |row|
    #   id = row['id']
    #   converted_value = "'" + eval(row['parameter_values']).stringify_keys.to_json + "'"
    #   execute "UPDATE computations
    #                   SET parameter_values = #{converted_value}
    #                   WHERE id = #{id}"
    # end
  end 
end
