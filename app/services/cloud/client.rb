# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/ClassLength

require 'net/http'
require 'json'
require 'securerandom'

module Cloud
  class Client
    def initialize(user_token)
      if user_token.blank?
        Rails.logger.warn('Warning: blank user token passed to cloud client.')
      else
        @user_token = user_token
      end
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
      @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
    end

    def register_initial_config(username, payload)
      if payload.present?
        config = "username=#{username};password=_placeholder_;script=#{payload}"
      end

      body = {
        appliance_configuration_template: {
          name: "template_#{SecureRandom.hex}",
          payload: config,
          appliance_type_id: @appliance_type_id
        }
      }

      req = create_request(
        :post,
        "#{@atmosphere_url}/api/v1/appliance_configuration_templates",
        body
      )
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @template_id = res_hash['appliance_configuration_template']['id']
    end

    def spawn_appliance
      if @appliance_set_id && @template_id

        body = {
          appliance: {
            appliance_set_id: @appliance_set_id,
            name: "cloud_step_#{SecureRandom.hex}",
            configuration_template_id: @template_id
          }
        }

        req = create_request(:post, "#{@atmosphere_url}/api/v1/appliances", body)
        res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end

        res_hash = JSON.parse(res.body)

        # Obtain ID from body
        @appliance_id = res_hash['appliance']['id']

        # Return appliance id
        @appliance_id.to_s
      end
    end

    def spawn_appliance_set
      request = {}
      request[:appliance_set] = {
        name: 'Cloud pipeline steps',
        priority: 50,
        appliance_set_type: 'workflow',
        optimization_policy: 'manual',
        appliances: []
      }

      body = {
        appliance_set: {
          appliance_set_type: 'workflow'
        }
      }

      req = create_request(:post, "#{@atmosphere_url}/api/v1/appliance_sets", body)
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @appliance_set_id = res_hash['appliance_set']['id']
    end

    def update_computation(c)
      req = create_request(:get, "#{@atmosphere_url}/api/v1/appliance/#{c.appliance_id}")
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain vm ids from body
      res_hash['virtual_machine']['virtual_machine_ids'].each do |vm|
        query_vm(c, vm)
      end
    end

    def query_vm(c, vm)
      req = create_request(:get, "#{@atmosphere_url}/api/v1/virtual_machine/#{vm}")
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain state from body
      status res_hash['virtual_machine']['state']

      Rails.logger.debug "VM QUERY: #{res_hash.inspect}"

      # TODO: need more robust status handling (esp. for error states)
      case state
      when 'build'
        c.update_attributes(status: 'queued')
      when 'active'
        c.update_attributes(status: 'running')
      when 'shutoff'
        c.update_attributes(status: 'finished')
      when 'error'
        c.update_attributes(status: 'error')
      end
    end

    def cleanup
      delete_appliance_set
      delete_config_template
    end

    private

    def create_request(type, path, body = '')
      url = URI.parse(path)
      case type
      when :post
        req = Net::HTTP::Post.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"
        req['Content-Type'] = 'application/json'
        req.body = body.to_json
      when :get
        req = Net::HTTP::Get.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"
        req['Content-Type'] = 'application/json'
      when :delete
        req = Net::HTTP::Delete.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"
      end
      req
    end

    def delete_appliance_set
      if @appliance_set_id
        req = create_request(
          :delete,
          "#{@atmosphere_url}/api/v1/appliance_sets/#{@appliance_set_id}"
        )
        Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end
      end
    end

    def delete_config_template
      if @template_id
        req = create_request(
          :delete,
          "#{@atmosphere_url}/api/v1/appliance_configuration_templates/#{@template_id}"
        )
        Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/ClassLength
