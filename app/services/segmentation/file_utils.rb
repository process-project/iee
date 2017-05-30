# frozen_string_literal: true

module Segmentation
  module FileUtils
    def strip_local_filename(file_path)
      file_path.gsub(%r{.*\/}, '')
    end
  end
end
