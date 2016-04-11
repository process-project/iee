FactoryGirl.define do
  factory :patient do
    case_number { 'c' + Faker::Number.number(6).to_s }
  end
end
