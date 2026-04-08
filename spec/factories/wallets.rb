FactoryBot.define do
  factory :wallet do
    association :user
    sequence(:name) { |n| "Carteira #{n}" }
    description { "Carteira para testes" }
  end
end
