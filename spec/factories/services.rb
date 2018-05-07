# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    sequence(:uri) { |n| "http://service#{n}.uri.pl" }

    sequence(:uri_aliases) do |n|
      ["http://service#{n}.first.alias.pl",
       "http://service#{n}.second.alias.pl"]
    end

    users { [create(:user)] }
  end
end
