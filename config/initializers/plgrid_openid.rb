# frozen_string_literal: true

require 'openid/fetchers'

Devise.setup do |config|
  AX = OmniAuth::Strategies::OpenID::AX

  AX[:proxy] = 'http://openid.plgrid.pl/certificate/proxy'
  AX[:userCert] = 'http://openid.plgrid.pl/certificate/userCert'
  AX[:proxyPrivKey] = 'http://openid.plgrid.pl/certificate/proxyPrivKey'
  AX[:POSTresponse] = 'http://openid.plgrid.pl/POSTresponse'

  config.omniauth :open_id,
                  require: 'omniauth-openid',
                  required: [
                    AX[:email],
                    AX[:name],
                    AX[:proxy],
                    AX[:userCert],
                    AX[:proxyPrivKey],
                    AX[:POSTresponse]
                  ]

  OpenID.fetcher.ca_file = Rails.root.join('config', 'ssl',
                                           'DigiCertAssuredIDRootCA.pem').to_s
end

module OpenID
  module AX
    class AttrInfo
      def initialize(type_uri, _ns_alias = nil, required = false, count = 1)
        @type_uri = type_uri
        @count = count
        @required = required
        @ns_alias = uri_to_alias(type_uri)
      end

      private

      def uri_to_alias(uri)
        case uri
        when 'http://openid.plgrid.pl/certificate/proxy'
          'proxy'
        when 'http://openid.plgrid.pl/certificate/userCert'
          'userCert'
        when 'http://openid.plgrid.pl/certificate/proxyPrivKey'
          'proxyPrivKey'
        when 'http://openid.plgrid.pl/POSTresponse'
          'POSTresponse'
        end
      end
    end
  end
end

module OmniAuth
  module Strategies
    class OpenID
      alias old_ax_user_info ax_user_info

      def ax_user_info
        ax = ::OpenID::AX::FetchResponse.from_success_response(openid_response)

        old_ax_user_info.tap do |user_info|
          user_info['proxy'] = get_proxy_element(ax, :proxy)
          user_info['userCert'] = get_proxy_element(ax, :userCert)
          user_info['proxyPrivKey'] = get_proxy_element(ax, :proxyPrivKey)
        end
      end

      def identifier
        "https://openid.plgrid.pl/#{identifier_postfix}"
      end

      private

      def identifier_postfix
        login = current_user&.plgrid_login
        login.presence || 'gateway'
      end

      def current_user
        @current_user ||= env['warden'].authenticate(scope: :user)
      end

      # rubocop:disable Naming/UncommunicativeMethodParamName
      def get_proxy_element(ax, id)
        ax.get_single(OmniAuth::Strategies::OpenID::AX[id])&.gsub('<br>', "\n")
      end
      # rubocop:enable Naming/UncommunicativeMethodParamName
    end
  end
end
