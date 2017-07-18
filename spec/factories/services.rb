# frozen_string_literal: true

require 'factory_girl/service_helper'

FactoryGirl.define do
  factory :service do
    uri { FactoryGirl::ServiceHelper.uniq_uri }

    uri_aliases do
      uri_alias1 = FactoryGirl::ServiceHelper.uniq_uri(uri)
      uri_alias2 = FactoryGirl::ServiceHelper.uniq_uri(uri, uri_alias1)
      [uri_alias1, uri_alias2]
    end

    users { [create(:user)] }
  end
end
