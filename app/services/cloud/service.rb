# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

module Cloud
  class Service
    def initialize(user)
      if user.token.blank?
        Rails.logger.warn('Warning: blank user token in cloud start appliance service.')
      else
        @user_token = user.token
      end
      @username = user.email
      @atmosphere_url = Rails.configuration.constants['cloud']['atmosphere_url']
      @appliance_type_id = Rails.configuration.constants['cloud']['computation_appliance_type']
      @template_id = Rails.configuration.constants['cloud']['computation_config_template']
    end

    protected

    attr_reader :user_token, :username, :atmosphere_url, :appliance_type_id, :template_id

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
      [url, req]
    end
  end

  class Exception < RuntimeError
  end
end

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
