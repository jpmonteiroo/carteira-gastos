require "rails_helper"

RSpec.describe Metrics::DashboardPresenter do
  let(:helpers) { ApplicationController.helpers }
  let(:data) do
    {
      income_total: BigDecimal("1000.0"),
      expense_total: BigDecimal("500.0"),
      balance: BigDecimal("500.0"),
      transaction_count: 3,
      average_expense: BigDecimal("250.0"),
      largest_expense: BigDecimal("300.0"),
      expense_timeline: [
        { point: Date.new(2026, 4, 6), value: BigDecimal("200.0") },
        { point: Date.new(2026, 4, 7), value: BigDecimal("300.0") }
      ],
      expenses_by_category: [
        { label: "Moradia", value: BigDecimal("300.0") },
        { label: "Mercado", value: BigDecimal("200.0") }
      ],
      amounts_by_type: [
        { transaction_type: "income", value: BigDecimal("1000.0") },
        { transaction_type: "expense", value: BigDecimal("500.0") }
      ],
      expenses_by_status: [
        { status: "paid", value: BigDecimal("300.0") },
        { status: "pending", value: BigDecimal("200.0") }
      ]
    }
  end

  subject(:presenter) do
    described_class.new(
      data: data,
      helpers: helpers,
      period: "week"
    )
  end

  it "formats the chart and summary data for the metrics view" do
    expect(presenter.income_total).to eq(BigDecimal("1000.0"))
    expect(presenter.expense_total).to eq(BigDecimal("500.0"))
    expect(presenter.balance).to eq(BigDecimal("500.0"))
    expect(presenter.transaction_count).to eq(3)

    expect(presenter.expense_timeline).to eq(
      [
        { label: "06/04", value: BigDecimal("200.0"), meta: "R$ 200,00" },
        { label: "07/04", value: BigDecimal("300.0"), meta: "R$ 300,00" }
      ]
    )
    expect(presenter.expenses_by_category).to eq(
      [
        { label: "Moradia", value: BigDecimal("300.0"), meta: "60% do total", hint: "R$ 300,00", tone: :rose },
        { label: "Mercado", value: BigDecimal("200.0"), meta: "40% do total", hint: "R$ 200,00", tone: :rose }
      ]
    )
    expect(presenter.amounts_by_type).to eq(
      [
        { label: "Receita", value: BigDecimal("1000.0"), meta: "67% do volume", hint: "R$ 1.000,00", tone: :emerald },
        { label: "Despesa", value: BigDecimal("500.0"), meta: "33% do volume", hint: "R$ 500,00", tone: :rose }
      ]
    )
    expect(presenter.expenses_by_status).to eq(
      [
        { label: "Pago", value: BigDecimal("300.0"), meta: "60% das despesas", hint: "R$ 300,00", tone: :emerald },
        { label: "Pendente", value: BigDecimal("200.0"), meta: "40% das despesas", hint: "R$ 200,00", tone: :amber }
      ]
    )
  end
end
