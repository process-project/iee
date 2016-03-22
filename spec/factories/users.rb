FactoryGirl.define do
  factory :user, aliases: [:author] do
    email { Faker::Internet.email }
    password '12345678'

    trait :plgrid do
      plgrid_login { Faker::Name.name }
    end

    factory :plgrid_user, traits: [:plgrid]
  end
end
