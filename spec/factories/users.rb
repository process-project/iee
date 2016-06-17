FactoryGirl.define do
  factory :group do
    name { Faker::Name.name }
    
    factory :supervisor_group do
      name "supervisor"
    end
  end
  
  factory :user do
    email { Faker::Internet.email }
    password '12345678'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :plgrid do
      plgrid_login { Faker::Name.name }
    end
    
    trait :approved do
      approved true
    end
    
    trait :supervisor do
      after(:create) do |user, evaluator|
        create_list(:supervisor_group, 1, users: [user])
      end
    end

    factory :approved_user, traits: [:approved]
    factory :plgrid_user, parent: :approved_user, traits: [:plgrid]
    factory :supervisor_user, parent: :approved_user, traits: [:supervisor]
  end
end
