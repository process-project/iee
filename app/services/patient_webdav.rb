# frozen_string_literal: true
class PatientWebdav
  def initialize(user, options = {})
    @user = user
    @dav_client = options.fetch(:client) { Webdav::FileStore.new(user) }
  end

  def r_mkdir(path)
    @dav_client.r_mkdir(path)
  end

  def delete(path)
    @dav_client.delete(path)
  end
end
