FactoryGirl.define do
  factory :data_file do
    name { Faker::Lorem.sentence }
    data_type 0
    patient
  end
end
