# frozen_string_literal: true

module Patients
  class Details
    def initialize(patient_case, user)
      @patient_case = patient_case
      @token = user.token
    end

    def call
      service_calls.reduce do |result, current|
        return current if current[:status] == :error
        return result if result[:status] == :error
        result.merge(current) do |_, old_value, new_value|
          new_value.is_a?(Array) ? (old_value + new_value) : new_value
        end
      end
    end

    private

    def service_calls
      [
        fetch_details('patient_basic.json', :basic_values),
        fetch_details('patient_details.json', :real_values),
        fetch_details('patient_details_inferred.json', :inferred_values)
      ]
    end

    def fetch_details(payload_file, extraction)
      client = DataSets::Client.new(@token, payload_file, '{case_number}' => @patient_case)
      method(extraction).call(client.call)
    rescue StandardError => e
      level = extraction == :inferred_values ? 'warn' : 'error'
      Rails.logger.send(level, "Could not fetch patient details with unknown error: #{e.message}")
      {
        status: level.to_sym,
        message: "#{e.message.capitalize} of #{extraction.to_s.humanize(capitalize: false)}"
      }
    end

    def real_values(csv)
      create_details(
        (1..(csv.size - 1)).map { |row| real_event(csv, row) }
      )
    end

    def basic_values(csv)
      create_details(
        [[
          entry('gender', csv_value(csv, 1, 'gender_value'), 'real', 'default'),
          entry('birth_year', csv_value(csv, 1, 'year_of_birth_value'), 'real', 'default'),
          entry('current_age', parse_age(csv_value(csv, 1, 'year_of_birth_value')),
                'computed', 'success')
        ]]
      )
    end

    def inferred_values(csv)
      create_details(
        (1..(csv.size - 1)).map do |row|
          [
            entry('state', csv_value(csv, row, 'ds_type_item'), 'inferred', 'default'),
            entry('elvmin', csv_value(csv, row, 'com_elvmin_value'), 'inferred', 'warning'),
            entry('elvmax', csv_value(csv, row, 'com_elvmax_value'), 'inferred', 'warning')
          ]
        end
      )
    end

    def real_event(csv, row)
      [
        entry('date', parse_date(csv_value(csv, row, 'ds_date_date')), 'real', 'default'),
        entry('state', csv_value(csv, row, 'ds_type_value'), 'real', 'default'),
        entry('age', csv_value(csv, row, 'age_value'), 'real', 'default'),
        entry('height', csv_value(csv, row, 'ds_height_value'), 'real', 'default'),
        entry('weight', csv_value(csv, row, 'ds_weight_value'), 'real', 'default')
      ]
    end

    def parse_date(value)
      value.present? ? Date.parse(value) : ''
    end

    def parse_age(value)
      value.present? ? (Time.current.year - value.to_i) : ''
    end

    def create_details(entries)
      { status: :ok, payload: entries }
    end

    def entry(name, value, type, style)
      { name: name, value: value, type: type, style: style }
    end

    def csv_value(csv, row, field)
      csv[row][csv[0].index(field)]
    end
  end
end
