# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

require 'net/http'
require 'json'
require 'securerandom'

module Cloud
  class Start < Cloud::Service
    def initialize(user, script)
      super(user)
      @script = script
    end

    def call
      spawn_appliance_set
      spawn_appliance
    end

    private

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

      url, req = create_request(:post, "#{@atmosphere_url}/api/v1/appliance_sets", body)
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain ID from body
      @appliance_set_id = res_hash['appliance_set']['id']
    end

    def spawn_appliance
      if @appliance_set_id && @template_id

        body = {
          appliance: {
            appliance_set_id: @appliance_set_id,
            name: "cloud_step_#{SecureRandom.hex}",
            configuration_template_id: @template_id,
            params: {
              username: username,
              payload: @script
            }
          }
        }

        url, req = create_request(:post, "#{@atmosphere_url}/api/v1/appliances", body)
        res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
          http.request(req)
        end

        res_hash = JSON.parse(res.body)

        # Obtain ID from body
        @appliance_id = res_hash['appliance']['id']
        Rails.logger.debug("Got appliance id: #{@appliance_id}")
        # Return appliance id
        @appliance_id.to_s
      end
    end

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
      [url, req]
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
