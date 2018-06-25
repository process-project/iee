# frozen_string_literal: true

module Cloud
  class Update
    def initialize(user, options = {})
      @user = user
      @user_token = user.token
      @on_finish_callback = options[:on_finish_callback]
      @updater = options[:updater]
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
      @client = Cloud::Client.new(@user_token)
    end

    def call
      active_computations.each do |c|
        update_computation(c) if c.appliance_id
      end
    end

    def update_computation(c)
      new_status = @client.update_computation(c)
      if new_status != c.status
        c.update_attributes(status: status)
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
  end
end
