# frozen_string_literal: true

module Webdav
  class MoveFile
    def initialize(dav_client, from, to)
      @dav_client = dav_client
      @from = from
      @to = to
    end

    def call
      @dav_client.move(@from, @to)
    end
  end
end
