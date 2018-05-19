# frozen_string_literal: true

module Cloud
  class Update
    def initialize(user, options = {})
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
      @client.update_computation(c)
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
