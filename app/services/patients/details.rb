# frozen_string_literal: true

require 'faraday'

module Patients
  class Details
    def initialize(patient_case, user)
      @patient_case = patient_case
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
        fetch_details(payload('patient_details.json'), :real_values),
        fetch_details(payload('patient_details_inferred.json'), :inferred_values)
      ]
    end

    def fetch_details(payload, extraction)
      csv_value = JSON.parse(call_data_set_service(payload).body)['queryCSVResponse']
      method(extraction).call(to_csv(csv_value))
    rescue StandardError => e
      Rails.logger.error("Could not fetch patient details with unknown error: #{e.message}")
      { status: :error, message: e.message }
    end

    def real_values(csv)
      create_details(first_values(csv).concat(last_values(csv)))
    end

    def inferred_values(csv)
      create_details(
        [entry('elvmin', csv_value(csv, 'dataset_com_elvmin_value'), 'inferred', 'warning')]
      )
    end

    def url
      Rails.configuration.constants['data_sets']['url'] +
        Rails.configuration.constants['data_sets']['api_url_path']
    end

    def call_data_set_service(payload)
      Faraday::Connection.new(
        url: url,
        ssl: { ca_file: Rails.root.join('config', 'data_sets', 'quovadis_root_ca.pem').to_s }
      ).post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['Accept'] = 'application/json'
        request.headers['Cookie'] = "access_token=#{@token}"
        request.body = payload
      end
    end

    def to_csv(csv_value)
      csv = CSV.parse(csv_value)

      if csv.length > 1
        csv
      else
        raise StandardError, I18n.t('errors.patient_details.empty_result')
      end
    end

    def first_values(csv)
      [
        entry('gender', csv_value(csv, 'gender_value'), 'real', 'default'),
        entry('birth_year', csv_value(csv, 'year_of_birth_value'), 'real', 'default'),
        entry('age', csv_value(csv, 'age_value'), 'real', 'default'),
        entry('current_age', Time.current.year - csv_value(csv, 'year_of_birth_value').to_i + 1,
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

    def payload(payload_file)
      File.read(Rails.root.join('config', 'data_sets', 'payloads', payload_file)).
        gsub('{case_number}', @patient_case)
    end
  end
end
