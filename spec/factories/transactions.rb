FactoryBot.define do
  factory :transaction do
    user
    wallet { association(:wallet, user: user) }
    category { association(:category, :expense, user: user) }
    date { Date.current }
    amount { 99.90 }
    transaction_type { category.kind }
    status { "pending" }
    description { "Transacao de teste" }
  end
end
