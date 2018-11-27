# frozen_string_literal: true

module DataFiles
  class Destroy
    def initialize(paths)
      @paths = paths
    end

    def call
      all_data_files.
        find_each(batch_size: 50) { |df| df.destroy if deleted?(df) }
    end

    private

    def all_data_files
      DataFile.eager_load(:patient, output_of: :patient, input_of: :patient)
    end

    def deleted?(data_file)
      data_file_path = File.join('/', data_file.path)
      @paths.any? { |path| data_file_path.start_with?(path) }
    end
  end
end
