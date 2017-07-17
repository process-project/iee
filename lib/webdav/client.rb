# frozen_string_literal: true

require 'net/dav'

module Webdav
  class Client < Net::DAV
    def r_mkdir(path)
      path.split('/').inject('') do |p, el|
        File.join(p, el, '/').tap { |current_path| mkdir(current_path) }
      end
    end

    def mkdir(path)
      local_path = File.join('.', path)
      super(local_path) unless exists?(local_path)
    end

    def delete(path)
      local_path = File.join('.', path)
      super(local_path) if exists?(local_path)
    end

    def get_file(remote_path, local_filename)
      raise(ArgumentError, "File: #{local_filename} already exists.") if File.exist?(local_filename)

      File.open(local_filename, mode: 'w', encoding: 'ASCII-8BIT') do |file|
        get(remote_path) { |s| file.write(s) }
      end
    end

    def get_file_to_memory(remote_path)
      StringIO.open do |io|
        get(remote_path) { |s| io.write(s) }
        io.string
      end
    end

    def put_file(local_filename, remote_path)
      File.open(local_filename, 'r') do |file|
        put(remote_path, file, File.size(local_filename))
      end
    end
  end
end
