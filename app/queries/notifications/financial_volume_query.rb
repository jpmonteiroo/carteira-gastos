module Notifications
  class FinancialVolumeQuery
    DEFAULT_PERIOD = "month".freeze
    WARNING_THRESHOLD = 50
    DANGER_THRESHOLD = 80
    CRITICAL_THRESHOLD = 100

    def initialize(user:, wallet_id: nil, period: DEFAULT_PERIOD, reference_date: Date.current)
      @user = user
      @wallet_id = wallet_id
      @period = normalized_period(period)
      @reference_date = normalized_reference_date(reference_date)
    end

    def call
      wallet = selected_wallet

      {
        wallet: wallet,
        period: @period,
        reference_date: @reference_date,
        date_range: date_range,
        notifications: build_notifications(wallet)
      }
    end

    private

    def selected_wallet
      return @user.wallets.find_by(id: @wallet_id) if @wallet_id.present?

      @user.wallets.first
    end

    def date_range
      @date_range ||= ::Transactions::DateRange.resolve(period: @period, reference_date: @reference_date)
    end

    def build_notifications(wallet)
      return [] if wallet.blank?

      transactions = @user.transactions.where(wallet: wallet, date: date_range)
      income_total = transactions.incomes.sum(:amount).to_d
      expense_total = transactions.expenses.sum(:amount).to_d

      return [] if expense_total.zero?

      if income_total.zero?
        return [
          {
            tone: :rose,
            icon: "fa-circle-exclamation",
            title: "Despesas sem receitas no periodo",
            message: "Existem saidas registradas, mas nenhuma entrada para cobri-las no intervalo atual.",
            income_total: income_total,
            expense_total: expense_total,
            ratio_percentage: nil
          }
        ]
      end

      ratio_percentage = ((expense_total / income_total) * 100).round
      return [] if ratio_percentage < WARNING_THRESHOLD

      [
        {
          tone: notification_tone(ratio_percentage),
          icon: notification_icon(ratio_percentage),
          title: notification_title(ratio_percentage),
          message: notification_message(ratio_percentage),
          income_total: income_total,
          expense_total: expense_total,
          ratio_percentage: ratio_percentage
        }
      ]
    end

    def notification_tone(ratio_percentage)
      ratio_percentage >= DANGER_THRESHOLD ? :rose : :amber
    end

    def notification_icon(ratio_percentage)
      ratio_percentage > CRITICAL_THRESHOLD ? "fa-circle-exclamation" : "fa-triangle-exclamation"
    end

    def notification_title(ratio_percentage)
      if ratio_percentage > CRITICAL_THRESHOLD
        "Despesas acima das receitas"
      elsif ratio_percentage >= DANGER_THRESHOLD
        "Despesas em nivel critico"
      else
        "Despesas em ritmo de atencao"
      end
    end

    def notification_message(ratio_percentage)
      if ratio_percentage > CRITICAL_THRESHOLD
        "As despesas ultrapassaram a receita disponivel e pedem acao imediata."
      elsif ratio_percentage >= DANGER_THRESHOLD
        "As despesas ja pressionam o periodo e merecem acompanhamento de perto."
      else
        "As despesas chegaram a metade da receita do periodo selecionado."
      end
    end

    def normalized_period(period)
      period.to_s.presence_in(::Constants::PERIODS) || DEFAULT_PERIOD
    end

    def normalized_reference_date(reference_date)
      reference_date.to_date
    rescue StandardError
      Date.current
    end
  end
end
