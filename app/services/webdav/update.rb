# frozen_string_literal: true
module Webdav
  class Update
    include Segmentation::OwncloudUtils
    def initialize(user, options = {})
      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @owncloud = WebdavClient.new(owncloud_url, owncloud_options)
    end

    def call
      return if active_computations.empty?

      update_computations
    end

    private

    def active_computations
      @ac ||= @user.computations.submitted_webdav
    end

    def update_computations
      active_computations.each { |computation| update_computation(computation) }
    end

    def update_computation(computation)
      finish_job(computation) if @owncloud.exists? output_path(computation)
    end

    def fjinish_job(computation)
      Segmentation::Finish.new(computation, @on_finish_callback).call
    end
  end
end
