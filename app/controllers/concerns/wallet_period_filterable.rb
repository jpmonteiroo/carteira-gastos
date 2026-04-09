module WalletPeriodFilterable
  extend ActiveSupport::Concern

  DEFAULT_PERIOD = "month".freeze

  private

  def load_wallet_period_scope(default_period: DEFAULT_PERIOD, allowed_periods: ::Transactions::DateRange::PERIODS)
    @wallets = current_user.wallets.order(:name)
    @wallet = selected_wallet
    @available_periods = allowed_periods
    @period = params[:period].to_s.presence_in(allowed_periods) || default_period
    @reference_date = parsed_reference_date
    @date_range = ::Transactions::DateRange.resolve(period: @period, reference_date: @reference_date)
    @filters_active = wallet_period_filters_active?
  end

  def selected_wallet
    return current_user.wallets.find(params[:wallet_id]) if params[:wallet_id].present?

    current_user.wallets.first
  end

  def parsed_reference_date
    Date.parse(params[:reference_date].to_s)
  rescue StandardError
    Date.current
  end

  def wallet_period_filters_active?
    params[:wallet_id].present? || params[:period].present? || params[:reference_date].present?
  end
end
