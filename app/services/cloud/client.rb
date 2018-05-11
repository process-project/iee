# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

require 'net/http'
require 'json'
require 'securerandom'

module Cloud
  class Client
    def initialize(user_token, atmosphere_url)
      if user_token.blank?
        Rails.logger.warn('Warning: blank user token passed to cloud client.')
      else
        @user_token = user_token
      end
      @atmosphere_url = atmosphere_url
      @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
    end

    def register_initial_config(username, payload) # rubocop:disable Metrics/MethodLength
      if payload.present?
        config = "username=#{username};password=_placeholder_;script=#{payload}"
      end

      request = {}
      request[:appliance_configuration_template] = {
        name: "template_#{SecureRandom.hex}",
        payload: config,
        appliance_type_id: @appliance_type_id
      }

      url = URI.parse(@atmosphere_url + '/api/v1/appliance_configuration_templates')
      req = Net::HTTP::Post.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = request.to_json

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @template_id = res_hash['appliance_configuration_template']['id']
    end

    def spawn_appliance # rubocop:disable Metrics/MethodLength
      if @appliance_set_id && @template_id

        request = {}
        request[:appliance] = {
          appliance_set_id: @appliance_set_id,
          name: "cloud_step_#{SecureRandom.hex}",
          configuration_template_id: @template_id
        }

        url = URI.parse(@atmosphere_url + '/api/v1/appliances')
        req = Net::HTTP::Post.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"
        req['Content-Type'] = 'application/json'
        req.body = request.to_json

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

    def spawn_appliance_set # rubocop:disable Metrics/MethodLength
      request = {}
      request[:appliance_set] = {
        name: 'Cloud pipeline steps',
        priority: 50,
        appliance_set_type: 'workflow',
        optimization_policy: 'manual',
        appliances: []
      }
      simple_req = {}
      simple_req[:appliance_set] = { appliance_set_type: 'workflow' }

      url = URI.parse(@atmosphere_url + '/api/v1/appliance_sets')
      req = Net::HTTP::Post.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = simple_req.to_json

      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @appliance_set_id = res_hash['appliance_set']['id']
    end

    def cleanup
      delete_appliance_set
      delete_config_template
    end

    def delete_appliance_set
      if @appliance_set_id
        url = URI.parse(@atmosphere_url + '/api/v1/appliance_sets' + @appliance_set_id.to_s)
        req = Net::HTTP::Delete.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"

        Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end
      end
    end

    def delete_config_template
      if @template_id
        url = URI.parse(
          @atmosphere_url + '/api/v1/appliance_configuration_templates' + @template_id.to_s
        )
        req = Net::HTTP::Delete.new(url.to_s)
        req['Authorization'] = "Bearer #{@user_token}"

        Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end
      end
    end
  end
end
