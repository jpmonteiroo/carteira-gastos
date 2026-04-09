require "rails_helper"

RSpec.describe Notifications::FinancialVolumeQuery do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user) }
  let(:income_category) { create(:category, :income, user: user, name: "Salario") }
  let(:expense_category) { create(:category, :expense, user: user, name: "Moradia") }

  around do |example|
    travel_to(Date.new(2026, 4, 8)) { example.run }
  end

  it "returns an amber notification when expenses reach 50% of income" do
    create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1000)
    create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 500)

    result = described_class.new(user: user, wallet_id: wallet.id).call

    expect(result[:notifications]).to contain_exactly(
      include(
        tone: :amber,
        title: "Despesas em ritmo de atencao",
        ratio_percentage: 50,
        income_total: BigDecimal("1000.0"),
        expense_total: BigDecimal("500.0")
      )
    )
  end

  it "returns a red notification when expenses reach 80% of income" do
    create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1000)
    create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 800)

    result = described_class.new(user: user, wallet_id: wallet.id).call

    expect(result[:notifications]).to contain_exactly(
      include(
        tone: :rose,
        title: "Despesas em nivel critico",
        ratio_percentage: 80
      )
    )
  end

  it "returns a red notification when expenses exceed income" do
    create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1000)
    create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 1200)

    result = described_class.new(user: user, wallet_id: wallet.id).call

    expect(result[:notifications]).to contain_exactly(
      include(
        tone: :rose,
        title: "Despesas acima das receitas",
        ratio_percentage: 120
      )
    )
  end

  it "returns a red notification when there are expenses but no income" do
    create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 400)

    result = described_class.new(user: user, wallet_id: wallet.id).call

    expect(result[:notifications]).to contain_exactly(
      include(
        tone: :rose,
        title: "Despesas sem receitas no periodo",
        ratio_percentage: nil
      )
    )
  end

  it "returns no notifications below the warning threshold" do
    create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1000)
    create(:transaction, user: user, wallet: wallet, category: expense_category, status: "paid", date: Date.new(2026, 4, 4), amount: 300)

    result = described_class.new(user: user, wallet_id: wallet.id).call

    expect(result[:notifications]).to eq([])
  end
end
