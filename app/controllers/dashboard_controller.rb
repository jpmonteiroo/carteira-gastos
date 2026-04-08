class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @wallets = current_user.wallets.order(:name)
    @wallet = selected_wallet

    @period = params[:period].presence || "month"
    @reference_date = parsed_reference_date
    @filters_active = filters_active?

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

  def selected_wallet
    return current_user.wallets.find(params[:wallet_id]) if params[:wallet_id].present?
    current_user.wallets.first
  end

  def parsed_reference_date
    Date.parse(params[:reference_date])
  rescue StandardError
    Date.current
  end

  def base_transactions
    scope = current_user.transactions.where(wallet: @wallet)

    case @period
    when "month"
      scope.where(date: @reference_date.beginning_of_month..@reference_date.end_of_month)
    when "quarter"
      scope.where(date: @reference_date.beginning_of_quarter..@reference_date.end_of_quarter)
    when "semester"
      semester_range(scope)
    when "year"
      scope.where(date: @reference_date.beginning_of_year..@reference_date.end_of_year)
    else
      scope
    end
  end

  def semester_range(scope)
    if @reference_date.month <= 6
      scope.where(date: Date.new(@reference_date.year, 1, 1)..Date.new(@reference_date.year, 6, 30))
    else
      scope.where(date: Date.new(@reference_date.year, 7, 1)..Date.new(@reference_date.year, 12, 31))
    end
  end

  def filters_active?
    params[:wallet_id].present? || params[:period].present? || params[:reference_date].present?
  end
end
