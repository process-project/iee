# frozen_string_literal: true

require 'open3'

module Vapor
  VERSION  = File.read(Rails.root.join('VERSION')).strip.freeze
  REVISION = begin
    stdin, stdout, = Open3.popen3('git log --pretty=format:%h -n 1')
    stdin.close

    stdout.gets
  end
end
