FactoryGirl.define do
  factory :user, aliases: [:author] do
    email { Faker::Internet.email }
    password '12345678'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :plgrid do
      plgrid_login { Faker::Name.name }
    end

    factory :plgrid_user, traits: [:plgrid]
  end
end
