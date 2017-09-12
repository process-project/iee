# frozen_string_literal: true

require 'rest-client'

module Patients
  class Details
    def initialize(patient_case, token)
      @patient_case = patient_case
      @token = token
    end

    def call
      invoke_service(@patient_case, @token)
    end

    private

    def invoke_service(patient_id, token)
      to_details(JSON.parse(make_the_call(patient_id, token).body)['queryCSVResponse'])
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("Could not fetch patient details for patient #{patient_id} with "\
        "status code #{e.response.code}")
      nil
    rescue StandardError => e
      Rails.logger.error("Could not fetch patient details with unknown error: #{e.message}")
      nil
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
        nil
      end
    end

    def make_the_call(patient_id, token)
      RestClient::Request.execute(
        method: :post,
        url: url,
        payload: payload(patient_id),
        headers: { content_type: :json, accept: :json, cookie: "access_token=#{token}" },
        ssl_ca_file: Rails.root.join('config', 'data_sets', 'quovadis_root_ca.pem').to_s
      )
    end

    def create_details(csv)
      {
        gender: csv_value(csv, 'gender_value'),
        birth_year: csv_value(csv, 'year_of_birth_value'),
        age: csv_value(csv, 'age_value'),
        height: csv_value(csv, 'ds_height_value'),
        weight: csv_value(csv, 'ds_weight_value')
      }
    end

    def csv_value(csv, field)
      csv[1][csv[0].index(field)]
    end
  end
end
