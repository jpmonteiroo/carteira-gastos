require "rails_helper"

RSpec.describe Metrics::DashboardQuery do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user) }
  let(:income_category) { create(:category, :income, user: user, name: "Salario") }
  let(:housing_category) { create(:category, :expense, user: user, name: "Moradia") }
  let(:food_category) { create(:category, :expense, user: user, name: "Alimentacao") }
  let(:scope) { user.transactions.where(wallet: wallet, date: date_range) }
  let(:date_range) { Date.new(2026, 4, 1)..Date.new(2026, 4, 30) }

  it "returns consolidated totals and grouped metric data for the selected period" do
    create(:transaction, user: user, wallet: wallet, category: income_category, transaction_type: "income", status: "received", date: Date.new(2026, 4, 3), amount: 1500)
    create(:transaction, user: user, wallet: wallet, category: housing_category, status: "paid", date: Date.new(2026, 4, 5), amount: 600)
    create(:transaction, user: user, wallet: wallet, category: food_category, status: "pending", date: Date.new(2026, 4, 7), amount: 150)
    create(:transaction, user: user, wallet: wallet, category: food_category, status: "canceled", date: Date.new(2026, 4, 9), amount: 50)

    result = described_class.new(scope: scope, period: "month", date_range: date_range).call

    expect(result).to include(
      income_total: BigDecimal("1500.0"),
      expense_total: BigDecimal("800.0"),
      balance: BigDecimal("700.0"),
      transaction_count: 4,
      average_expense: BigDecimal("266.6666666666666667"),
      largest_expense: BigDecimal("600.0")
    )

    expect(result[:expense_timeline]).to include(
      { point: Date.new(2026, 4, 5), value: BigDecimal("600.0") },
      { point: Date.new(2026, 4, 7), value: BigDecimal("150.0") },
      { point: Date.new(2026, 4, 9), value: BigDecimal("50.0") }
    )
    expect(result[:expense_timeline].find { |entry| entry[:point] == Date.new(2026, 4, 1) }).to eq(
      { point: Date.new(2026, 4, 1), value: BigDecimal("0.0") }
    )

    expect(result[:expenses_by_category]).to eq(
      [
        { label: "Moradia", value: BigDecimal("600.0") },
        { label: "Alimentacao", value: BigDecimal("200.0") }
      ]
    )
    expect(result[:amounts_by_type]).to eq(
      [
        { transaction_type: "income", value: BigDecimal("1500.0") },
        { transaction_type: "expense", value: BigDecimal("800.0") }
      ]
    )
    expect(result[:expenses_by_status]).to eq(
      [
        { status: "pending", value: BigDecimal("150.0") },
        { status: "paid", value: BigDecimal("600.0") },
        { status: "canceled", value: BigDecimal("50.0") }
      ]
    )
  end
end
