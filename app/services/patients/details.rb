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

    def basic_values(csv)
      create_details(
        [[
          entry(csv, 1, 'gender_value'),
          entry(csv, 1, 'year_of_birth_value')
        ]]
      )
    end

    def real_values(csv)
      create_details(
        (1..(csv.size - 1)).map { |row| real_event(csv, row) }
      )
    end

    def inferred_values(csv)
      create_details(
        (1..(csv.size - 1)).map { |row| inferred_event(csv, row) }
      )
    end

    def real_event(csv, row)
      [
        entry(csv, row, 'ds_date_date'),
        entry(csv, row, 'ds_type_value'),
        entry(csv, row, 'age_value'),
        entry(csv, row, 'ds_height_value', unit: 'cm'),
        entry(csv, row, 'ds_weight_value', unit: 'kg')
      ]
    end

    def inferred_event(csv, row)
      [
        entry(csv, row, 'ds_type_item'),
        entry(csv, row, 'com_elvmin_value', type: 'inferred', unit: 'mmHg/ml'),
        entry(csv, row, 'com_elvmax_value', type: 'inferred', unit: 'mmHg/ml'),
        entry(csv, row, 'com_tbv_value', type: 'inferred', unit: 'ml'),
        entry(csv, row, 'systemic_resistance_distal_value', type: 'inferred', unit: 'mmHg/ml'),
        entry(csv, row, 'systemic_resistance_proximal_value', type: 'inferred', unit: 'mmHg/ml')
      ]
    end

    def parse_date(value)
      value.present? ? Date.parse(value) : ''
    end

    def create_details(entries)
      { status: :ok, payload: entries }
    end

    def entry(csv, row, name, unit: nil, type: nil)
      value = csv_value(csv, row, name)
      style = case type
              when 'computed' then 'success'
              when 'inferred' then 'warning'
              else 'default'
              end
      { name: name, value: value, type: type, style: style, unit: unit }
    end

    def csv_value(csv, row, field)
      value = csv[row][csv[0].index(field)]
      case field
      when 'com_elvmin_value', 'com_elvmax_value', 'com_tbv_value' then value.to_f.round(3)
      when 'systemic_resistance_distal_value', 'systemic_resistance_proximal_value'
        value.to_f.round(3)
      when 'ds_date_date' then parse_date(value)
      else value
      end
    end
  end
end
