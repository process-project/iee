# frozen_string_literal: true

module Cloudify
  class Update
    def initialize(user, options = {})
      @user = user
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
    end

    def call
      Rails.logger.debug('CLOUDIFY COMPUTATION UPDATER CALLED...')

      return if active_computations.empty?
      update_computations
    end

    private

    def active_computations
      Rails.logger.debug('UPDATING CLOUDIFY COMPUTATIONS...')

      @ac ||= @user.computations.submitted_cloudify
    end

    def update_computations
      active_computations.each { |computation| update_computation(computation) }
    end

    def update_computation(computation)
      case computation.cloudify_status
      when 'deployment_started'
        Cloudify::RunInstallWorkflow.new(computation).call
      when 'install_workflow_launched'
        Cloudify::RunApplicationWorkflow.new(computation).call
      when 'application_workflow_launched'
        Cloudify::RunUninstallWorkflow.new(computation).call
      when 'uninstall_workflow_launched'
        Cloudify::DestroyDeployment.new(computation).call
      end
      # finish_job(computation) if results_ready?(computation)
    end

    def results_ready?(computation)
      # @segmentation.exists?(Webdav::Segmentation.output_path(computation))
    end

    def finish_job(computation)
      # ::Segmentation::Finish.new(computation, @on_finish_callback).call
      # @updater&.new(computation)&.call
    end
  end
end
