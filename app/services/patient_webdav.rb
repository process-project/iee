# frozen_string_literal: true
require 'net/dav'

class PatientWebdav
  def initialize(user, options = {})
    @user = user
    @dav_client = options.fetch(:client) { Webdav::FileStore.new(user) }
  end

  delegate :r_mkdir, :mkdir, :delete, to: :@dav_client
end
