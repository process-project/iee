# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/CyclomaticComplexity

module Cloud
  class Update
    def initialize(user, options = {})
      @user = user
      @user_token = user.token
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
    end

    def call
      active_computations.each do |c|
        update_computation(c) if c.appliance_id
      end
    end

    def update_computation(c)
      url, req = create_request(:get, "#{@atmosphere_url}/api/v1/appliances/#{c.appliance_id}")
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Assume finished if appliance no longer exists
      new_status = 'finished' if res_hash['appliance'].blank?

      new_status = 'active'
      # Obtain vm ids from body
      res_hash['appliance']['virtual_machine_ids'].each do |vm|
        vm_status = query_vm(vm)

        case vm_status
        when 'build'
          new_status = 'queued'
        when 'active'
          new_status = 'running'
        when 'shutoff'
          new_status = 'finished'
        when 'error'
          new_status = 'error'
        end

        next unless %w[finished error].include? new_status
        # We're done - clean up
        appliance_set_id = res_hash['appliance']['appliance_set_id']
        delete_appliance_set(appliance_set_id)
      end

      if new_status != c.status
        c.update_attributes(status: new_status)
        update(c)
      end

      on_finish_callback(c) if c.status == 'finished'
    end

    private

    def active_computations
      @ac ||= @user.computations.submitted_cloud
    end

    def on_finish_callback(computation)
      @on_finish_callback&.new(computation)&.call
    end

    def update(computation)
      @updater&.new(computation)&.call
    end

    def query_vm(vm)
      url, req = create_request(:get, "#{@atmosphere_url}/api/v1/virtual_machines/#{vm}")
      res = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      res_hash = JSON.parse(res.body)

      # Obtain state from body and return
      res_hash['virtual_machine']['state']
    end

    def delete_appliance_set(appliance_set_id)
      url, req = create_request(
        :delete,
        "#{@atmosphere_url}/api/v1/appliance_sets/#{appliance_set_id}"
      )
      Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        http.request(req)
      end
    end
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/CyclomaticComplexity
