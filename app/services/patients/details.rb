# frozen_string_literal: true

require 'faraday'

module Patients
  class Details
    def initialize(patient_case, user)
      @patient_case = patient_case
      @token = user.token
    end

    def call
      invoke_service(@patient_case, @token)
    end

    private

    def invoke_service(patient_id, token)
      to_details(JSON.parse(make_the_call(patient_id, token).body)['queryCSVResponse'])
    rescue StandardError => e
      Rails.logger.error("Could not fetch patient details with unknown error: #{e.message}")
      { status: :error, message: e.message }
    end

    def payload(patient_id)
      File.read(Rails.root.join('config', 'data_sets', 'payloads', 'patient_details.json')).
        gsub('{patient_id}', patient_id)
    end

    def url
      Rails.configuration.constants['data_sets']['url'] +
        Rails.configuration.constants['data_sets']['api_url_path']
    end

    def to_details(csv_value)
      csv = CSV.parse(csv_value)

      if csv.length > 1
        create_details(csv)
      else
        Rails.logger.warn("Data set result did not contain any value: #{csv_value}")
        { status: :error, message: I18n.t('errors.patient_details.empty_result') }
      end
    end

    def make_the_call(patient_id, token)
      Faraday::Connection.new(
        url: url,
        ssl: { ca_file: Rails.root.join('config', 'data_sets', 'quovadis_root_ca.pem').to_s }
      ).post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['Accept'] = 'application/json'
        request.headers['Cookie'] = "access_token=#{token}"
        request.body = payload(patient_id)
      end
    end

    def create_details(csv)
      {
        status: :ok,
        payload: patient_details(csv)
      }
    end

    def patient_details(csv)
      first_values(csv).concat(last_values(csv))
    end

    def entry(name, value, type, style)
      { name: name, value: value, type: type, style: style }
    end

    def csv_value(csv, field)
      csv[1][csv[0].index(field)]
    end

    def first_values(csv)
      [
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
        entry('weight', csv_value(csv, 'ds_weight_value'), 'real', 'default'),
        entry('bpprs', 130, 'inferred', 'warning'),
        entry('bpprd', 85, 'inferred', 'warning')
      ]
    end
  end
end
