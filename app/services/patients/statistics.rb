# frozen_string_literal: true

module Patients
  class Statistics
    def initialize(patients, user)
      @patients = patients || []
      @token = user.token
    end

    def call
      fetch_statistics
    end

    private

    def fetch_statistics
      constraints = @patients.map { |p| patient_constraint(p.case_number) }.join(',')
      client = DataSets::Client.new(@token,
                                    'patient_statistics.json',
                                    '{patient_id_constraints}' => constraints)
      create_details(client.call)
    rescue StandardError => e
      Rails.logger.error("Could not fetch patient statistics with unknown error: #{e.message}")
      { status: :error, message: e.message }
    end

    def patient_constraint(case_number)
      File.read(Rails.root.join('config', 'data_sets', 'payloads', 'patient_id_constraint.part')).
        gsub('{case_number}', case_number)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create_details(csv)
      entries = csv&.slice(1..-1) || []
      {
        status: :ok,
        count: entries.count,
        test: @patients.count - entries.count,
        berlin: entries.count { |p| p[0].include?('_B_') },
        sheffield: entries.count { |p| p[0].include?('_S_') },
        eindhoven: entries.count { |p| p[0].include?('-C-') },
        no_site: entries.count - entries.count { |p| p[0].index(/(_[BS]_|-C-)/) },
        females: entries.count { |p| p[2] == 'Female' },
        males: entries.count { |p| p[2] == 'Male' },
        no_gender: entries.count { |p| !%w[Male Female].include?(p[2]) },
        preop: entries.count { |p| p[1] == 'Pre-op' },
        postop: entries.count { |p| p[1] == 'Post-op' },
        no_state: entries.count { |p| !%w[Pre-op Post-op].include?(p[1]) }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
