# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
module Cloudify
  class Service
    def initialize(computation, options = {})
      @computation = computation
      @cloudify_user = cloudify_user
      @cloudify_password = cloudify_password
      @options = options
    end

    protected

    attr_reader :computation

    private

    def create_request(type, path, body = '')
      url = URI.parse(path)
      case type
      when :post
        req = Net::HTTP::Post.new(url.to_s)
        req.basic_auth @cloudify_user, @cloudify_password
        req['Tenant'] = 'default_tenant' # TODO: Parameterize
        req['Content-Type'] = 'application/json'
        req.body = body.to_json
      when :put
        req = Net::HTTP::Put.new(url.to_s)
        req.basic_auth @cloudify_user, @cloudify_password
        req['Tenant'] = 'default_tenant' # TODO: Parameterize
        req['Content-Type'] = 'application/json'
        req.body = body.to_json
      when :get
        req = Net::HTTP::Get.new(url.to_s)
        req.basic_auth @cloudify_user, @cloudify_password
        req['Tenant'] = 'default_tenant' # TODO: Parameterize
      when :delete
        req = Net::HTTP::Delete.new(url.to_s)
        req.basic_auth @cloudify_user, @cloudify_password
        req['Tenant'] = 'default_tenant' # TODO: Parameterize
      end
      [url, req]
    end

    def cloudify_url
      Rails.application.config_for('process')['cloudify']['url']
    end

    def cloudify_user
      Rails.application.config_for('process')['cloudify']['user']
    end

    def cloudify_password
      Rails.application.config_for('process')['cloudify']['password']
    end

    def cloudify_blueprint
      Rails.application.config_for('process')['cloudify']['blueprint']
    end

    def iee_deployment_name
      Rails.application.config_for('process')['cloudify']['iee_deployment_name']
    end

    def app_workflow_name
      Rails.application.config_for('process')['cloudify']['app_workflow_name']
    end
  end

  class Exception < RuntimeError
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
