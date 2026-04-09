class MetricsController < ApplicationController
  include WalletPeriodFilterable

  before_action :authenticate_user!

  def index
    load_wallet_period_scope
    return if @wallet.blank?

    @dashboard = Metrics::DashboardPresenter.new(
      data: dashboard_data,
      helpers: helpers,
      period: @period
    )
  end

  private

  def scoped_transactions
    current_user.transactions.where(wallet: @wallet, date: @date_range)
  end

  def dashboard_data
    Metrics::DashboardQuery.new(
      scope: scoped_transactions,
      period: @period,
      date_range: @date_range
    ).call
  end
end
