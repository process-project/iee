# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module Cloud
  class Update < ProxyService
    def initialize(user, options = {})
      @user_token = user.token
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
    end

    def call
      return if active_computations.empty?

      @ac.each do |c|
        update_computation(c) if c.appliance_id
      end
    end

    def update_computation(c) # rubocop:disable Metrics/MethodLength
      url = URI.parse(@atmosphere_url + "/api/v1/appliance/#{c.appliance_id}")
      req = Net::HTTP::Get.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = request.to_json
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      Rails.logger.debug "APPLIANCE QUERY: #{res_hash.inspect}"

      # Obtain vm ids from body
      res_hash['virtual_machine']['virtual_machine_ids'].each do |vm|
        query_vm(c, vm)
      end
    end

    def query_vm(c, vm) # rubocop:disable Metrics/MethodLength
      url = URI.parse(@atmosphere_url + "/api/v1/virtual_machine/#{vm}")
      req = Net::HTTP::Get.new(url.to_s)
      req['Authorization'] = "Bearer #{@user_token}"
      req['Content-Type'] = 'application/json'
      req.body = request.to_json

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

    private

    def active_computations
      @ac ||= @user.computations.submitted_cloud
    end

    def on_finish_callback(computation)
      @on_finish_callback&.new(computation)&.call
    end
  end
end
