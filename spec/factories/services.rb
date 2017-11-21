# frozen_string_literal: true

require 'factory_bot/service_helper'

FactoryBot.define do
  factory :service do
    uri { FactoryBot::ServiceHelper.uniq_uri }

    uri_aliases do
      uri_alias1 = FactoryBot::ServiceHelper.uniq_uri(uri)
      uri_alias2 = FactoryBot::ServiceHelper.uniq_uri(uri, uri_alias1)
      [uri_alias1, uri_alias2]
    end

    users { [create(:user)] }
  end
end
