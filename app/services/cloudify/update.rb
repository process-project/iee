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

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def update_computation(computation)
      case computation.cloudify_status
      when 'deployment_started'
        ActivityLogWriter.write_message(
          computation.pipeline.user, computation.pipeline, computation,
          'computation_status_change_queued'
        )
        Cloudify::RunInstallWorkflow.new(computation).call
      when 'install_workflow_launched'
        Cloudify::RunApplicationWorkflow.new(computation).call
      when 'application_workflow_launched'
        ActivityLogWriter.write_message(
          computation.pipeline.user, computation.pipeline, computation,
          'computation_status_change_running'
        )
        Cloudify::RunUninstallWorkflow.new(computation).call
      when 'uninstall_workflow_launched'
        ActivityLogWriter.write_message(
          computation.pipeline.user, computation.pipeline, computation,
          'computation_status_change_finished'
        )
        Cloudify::DestroyDeployment.new(computation).call
      end
      # finish_job(computation) if results_ready?(computation)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def results_ready?(computation) end

    def finish_job(computation)
      # @updater&.new(computation)&.call
    end
  end
end
