FactoryBot.define do
  factory :category do
    association :user
    sequence(:name) { |n| "Categoria #{n}" }
    kind { "expense" }
    color { "#0f766e" }

    trait :income do
      kind { "income" }
      sequence(:name) { |n| "Receita #{n}" }
    end

    trait :expense do
      kind { "expense" }
      sequence(:name) { |n| "Despesa #{n}" }
    end
  end
end
