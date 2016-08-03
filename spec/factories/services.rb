# frozen_string_literal: true
FactoryGirl.define do
  factory :service do
    uri do
      uri = URI.parse(Faker::Internet.url)
      "#{uri.scheme}://#{uri.host}"
    end
  end
end
