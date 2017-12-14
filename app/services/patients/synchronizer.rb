# frozen_string_literal: true

module Patients
  class Synchronizer
    def call
      all_cases = query_ready_patients

      existing_db_case_numbers = Patient.pluck(:case_number)

      all_cases.reject { |case_number, _| existing_db_case_numbers.include?(case_number) }.
        group_by(&:first).
        each do |case_number, cases|
          Rails.logger.info("Creating new ready patient, case number: #{case_number}")
          create_new_patient(case_number, cases.map(&:second))
        end
    end

    private

    def create_new_patient(case_number, modalities)
      patient = Patients::CreateProspective.new(user,
                                                Patient.new(case_number: case_number),
                                                modalities).call
      if patient.persisted?
        Rails.logger.info("New patient (#{patient.case_number}) created.")
      else
        raise ActiveRecord::RecordInvalid, patient
      end
    rescue StandardError => e
      Rails.logger.error("Problem creating patient (#{case_number}): #{e.message}")
    end

    def query_ready_patients
      client = DataSets::Client.new(user.token, 'ready_patients.json')
      cases(client.call)
    rescue StandardError => e
      Rails.logger.error("Could not fetch ready patients list: #{e.message}")
      return []
    end

    def cases(csv)
      # 1. Sometimes ArcQ returns duplicate items in the result array
      # 2. The 1st item is a header
      csv.uniq[1..-1]
    end

    def user
      User.find_by(email: Rails.configuration.constants['data_sets']['sync_user_email'])
    end
  end
end
