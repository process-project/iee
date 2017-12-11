# frozen_string_literal: true

require 'faraday'

module DataSets
  class Client
    def initialize(user_token, payload_file, interpolation = {})
      @interpolation = interpolation
      @token = user_token
      @payload_file = payload_file
    end

    def call
      payload = payload(@payload_file)
      csv_value = JSON.parse(call_data_set_service(payload).body)['queryCSVResponse']
      to_csv csv_value
    end

    private

    def url
      Rails.configuration.constants['data_sets']['url'] +
        Rails.configuration.constants['data_sets']['api_url_path']
    end

    # rubocop:disable Metrics/MethodLength
    def call_data_set_service(payload)
      Faraday::Connection.new(
        url: url,
        ssl: { ca_file: Rails.root.join('config', 'data_sets', 'quovadis_root_ca.pem').to_s }
      ).post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['Accept'] = 'application/json'
        request.headers['Cookie'] = "access_token=#{@token}"
        request.options.timeout = 4
        request.options.open_timeout = 4
        request.body = payload
      end
    end
    # rubocop:enable Metrics/MethodLength

    def to_csv(csv_value)
      csv = CSV.parse(csv_value)

      if csv.length > 1
        csv
      else
        raise StandardError, I18n.t('errors.patient_details.empty_result')
      end
    end

    def payload(payload_file)
      File.read(Rails.root.join('config', 'data_sets', 'payloads', payload_file)).
        gsub(Regexp.union(@interpolation.keys), @interpolation)
    end
  end
end
