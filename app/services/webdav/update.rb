# frozen_string_literal: true

module Webdav
  class Update
    def initialize(user, options = {})
      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @owncloud = Webdav::OwnCloud.new
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
      finish_job(computation) if results_ready?(computation)
    end

    def results_ready?(computation)
      @owncloud.exists?(Webdav::OwnCloud.output_path(computation))
    end

    def finish_job(computation)
      Segmentation::Finish.new(computation, @on_finish_callback).call
    end
  end
end
