# frozen_string_literal: true

module Liquid
  class StageIn < Liquid::Tag
    def initialize(tag_name, parameters, tokens)
      super
      @data_file_type_or_path, @filename = parameters.split(&:strip)
    end

    def render(context)
      filename, url = if DataFile.data_types.key? @data_file_type_or_path
                        extract_request_data_for_type(data_file_type: @data_file_type_or_path,
                                                      filename: @filename,
                                                      pipeline: context.registers[:pipeline])
                      else
                        extract_request_data_for_path(path: @data_file_type_or_path,
                                                      filename: @filename)
                      end

      "curl -H \"Authorization: Bearer #{context['token']}\" \"#{url}\" "\
      ">> \"$SCRATCHDIR/#{filename}\" --fail"
    end

    private

    def extract_request_data_for_type(data_file_type:, filename:, pipeline:)
      data_file = pipeline.data_file(data_file_type)
      # TODO; FIXME; Problem if a file does not exist in any of the input directories
      target_filename = filename || data_file&.name
      url = data_file.url
      [target_filename, url]
    end

    def extract_request_data_for_path(path:, filename:)
      url = File.join(Webdav::FileStore.url, Webdav::FileStore.path, path)
      target_filename = filename || File.basename(path)
      [target_filename, url]
    end
  end
end
