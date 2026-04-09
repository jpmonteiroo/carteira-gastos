class DashboardController < ApplicationController
  include WalletPeriodFilterable

  before_action :authenticate_user!

  def index
    load_wallet_period_scope(allowed_periods: %w[month quarter semester year])

    @transactions = base_transactions
    @income_total = @transactions.incomes.sum(:amount)
    @expense_total = @transactions.expenses.sum(:amount)
    @balance = @income_total - @expense_total

    @grouped_by_category = @transactions
      .joins(:category)
      .group("categories.name")
      .sum(:amount)

    @grouped_by_month = current_user.transactions
      .where(wallet: @wallet)
      .group_by_month_data(@reference_date.year)
  end

  private

  def base_transactions
    current_user.transactions.where(wallet: @wallet, date: @date_range)
  end
end
