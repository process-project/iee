# frozen_string_literal: true

FactoryBot.define do
  factory :device do
    sequence(:name) do |n|
      "SuperEngine/#{n}.0 (X11; Linux x86_64) SuperBrowser/#{n * 10}.0"
    end

    sequence(:accept_language) do |n|
      "pl-PL, pl;q=0.#{n + 1};en-US, en;q=0.#{n}"
    end

    user

    trait :chrome do
      sequence(:name) do |n|
        "Mozilla/#{n}.0 (X11; Linux x86_64) AppleWebKit/#{n * 100}.36 (KHTML, like Gecko)
          Chrome/63.0.3239.132 Safari/537.36"
      end
    end

    trait :firefox do
      sequence(:name) do |n|
        "Mozilla/#{n}.0 (X11; Ubuntu; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/#{n * 10}.0"
      end
    end
  end
end
