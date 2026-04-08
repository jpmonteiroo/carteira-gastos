user = User.find_or_create_by!(email: "admin@email.com") do |u|
  u.password = "123456"
  u.password_confirmation = "123456"
end

wallet = user.wallets.find_or_create_by!(name: "Carteira Principal")

food = user.categories.find_or_create_by!(name: "Alimentação", kind: "expense", color: "#ef4444")
salary = user.categories.find_or_create_by!(name: "Salário", kind: "income", color: "#22c55e")
transport = user.categories.find_or_create_by!(name: "Transporte", kind: "expense", color: "#3b82f6")

10.times do |i|
  user.transactions.create!(
    wallet: wallet,
    category: salary,
    date: Date.current.beginning_of_month + i.days,
    amount: 5000,
    transaction_type: "income",
    status: "paid",
    description: "Receita #{i + 1}"
  )

  user.transactions.create!(
    wallet: wallet,
    category: food,
    date: Date.current.beginning_of_month + i.days,
    amount: rand(20..150),
    transaction_type: "expense",
    status: "paid",
    description: "Despesa alimentação #{i + 1}"
  )

  user.transactions.create!(
    wallet: wallet,
    category: transport,
    date: Date.current.beginning_of_month + i.days,
    amount: rand(10..80),
    transaction_type: "expense",
    status: "pending",
    description: "Despesa transporte #{i + 1}"
  )
end
