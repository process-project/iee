# frozen_string_literal: true

module Projects
  class Details
    def initialize(project, user)
      @project = project
      @token = user.token
    end

    def call
      service_calls.reduce do |result, current|
        if current['status'] == :error
          current
        else
          result.merge(current) do |_, old_value, new_value|
            new_value.is_a?(Array) ? (old_value + new_value) : new_value
          end
        end
      end
    end

    private

    def service_calls
      [
        fetch_details('project_details.json', :real_values),
        fetch_details('project_details_inferred.json', :inferred_values)
      ]
    end

    def fetch_details(payload_file, extraction)
      client = DataSets::Client.new(@token, payload_file, '{project_name}' => @project)
      method(extraction).call(client.call)
    rescue StandardError => e
      Rails.logger.error("Could not fetch project details with unknown error: #{e.message}")
      { status: :error, message: e.message }
    end

    def real_values(csv)
      create_details(first_values(csv).concat(last_values(csv)))
    end

    def inferred_values(csv)
      create_details(
        [entry('elvmin', csv_value(csv, 'com_elvmin_value'), 'inferred', 'warning')]
      )
    end

    def first_values(csv)
      [
        entry('state', csv_value(csv, 'state_value'), 'real', 'default'),
        entry('gender', csv_value(csv, 'gender_value'), 'real', 'default'),
        entry('birth_year', csv_value(csv, 'year_of_birth_value'), 'real', 'default'),
        entry('age', csv_value(csv, 'age_value'), 'real', 'default'),
        entry('current_age', Time.current.year - csv_value(csv, 'year_of_birth_value').to_i,
              'computed', 'success')
      ]
    end

    def last_values(csv)
      [
        entry('height', csv_value(csv, 'ds_height_value'), 'real', 'default'),
        entry('weight', csv_value(csv, 'ds_weight_value'), 'real', 'default')
      ]
    end

    def create_details(entries)
      {
        status: :ok,
        payload: entries
      }
    end

    def entry(name, value, type, style)
      { name: name, value: value, type: type, style: style }
    end

    def csv_value(csv, field)
      csv[1][csv[0].index(field)]
    end
  end
end
