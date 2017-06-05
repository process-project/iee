# frozen_string_literal: true
require 'net/dav'

class PatientWebdav
  def initialize(user, options = {})
    @user = user
    @dav_client = options.fetch(:client) { Webdav::FileStore.new(user) }
  end

  def r_mkdir(path)
    @dav_client.r_mkdir(path) if webdav_enabled?
  end

  def delete(path)
    @dav_client.delete(path) if webdav_enabled?
  end

  def webdav_enabled?
    DataFile.synchronizer_class == WebdavDataFileSynchronizer
  end
end
