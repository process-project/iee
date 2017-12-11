# frozen_string_literal: true

module Patients
  class CreateProspective < Patients::Create
    def initialize(user, patient, modalities, options = {})
      super(user, patient, options)
      @modalities = modalities
    end

    protected

    def internal_call
      existing_modalities = @modalities.select { |modality| modality_exists?(modality) }
      if existing_modalities.empty?
        raise StandardError,
              "None of modalities (#{@modalities}) exist for patient (#{@patient.case_number})"
      end
      super
      existing_modalities.each { |modality| move_imaging_file(modality) }
      @patient.execute_data_sync(@user)
    end

    def move_imaging_file(modality)
      new_image_name = "imaging_#{@patient.case_number}_#{modality}_init.zip"

      # TODO: WebDAV COPY version, preferred, if Webbs#123 is fixed
      # @dav_client.copy(modality_path(modality), "#{@patient.inputs_dir}/#{new_image_name}")

      # TODO: WebDAV Download/Upload brute force method, less optimal but working
      local_path = Webdav::DownloadFile.new(@dav_client, modality_path(modality)).
                   call { new_image_name }
      Webdav::UploadFile.
        new(@dav_client, local_path, "#{@patient.inputs_dir}/#{new_image_name}").
        call

    rescue Net::HTTPServerException => e
      Rails.logger.error e
      raise StandardError, "Problem moving patient (#{@patient.case_number}) image file #{modality}"
    end

    def modality_exists?(modality)
      @dav_client.exists?(modality_path(modality))
    end

    def modality_path(modality)
      path = Rails.configuration.constants['file_store']['prospective_images_path']
      "#{path}#{@patient.case_number}/Initial_#{modality}/file.zip"
    end
  end
end
