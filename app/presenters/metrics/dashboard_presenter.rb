module Metrics
  class DashboardPresenter
    TIMELINE_MONTH_FORMAT = "%m/%Y".freeze
    TIMELINE_DAY_FORMAT = "%d/%m".freeze

    def initialize(data:, helpers:, period:)
      @data = data
      @helpers = helpers
      @period = period
    end

    def income_total
      fetch(:income_total)
    end

    def expense_total
      fetch(:expense_total)
    end

    def balance
      fetch(:balance)
    end

    def transaction_count
      fetch(:transaction_count)
    end

    def average_expense
      fetch(:average_expense)
    end

    def largest_expense
      fetch(:largest_expense)
    end

    def expense_timeline
      fetch(:expense_timeline).map do |entry|
        {
          label: timeline_label(entry.fetch(:point)),
          value: entry.fetch(:value),
          meta: @helpers.brl(entry.fetch(:value))
        }
      end
    end

    def expenses_by_category
      fetch(:expenses_by_category).map do |entry|
        total = entry.fetch(:value)

        {
          label: entry.fetch(:label),
          value: total,
          meta: "#{percentage(total, expense_total)} do total",
          hint: @helpers.brl(total),
          tone: :rose
        }
      end
    end

    def amounts_by_type
      total_amount = fetch(:amounts_by_type).sum { |entry| entry.fetch(:value) }

      fetch(:amounts_by_type).map do |entry|
        amount = entry.fetch(:value)
        transaction_type = entry.fetch(:transaction_type)

        {
          label: @helpers.transaction_type_label(transaction_type),
          value: amount,
          meta: "#{percentage(amount, total_amount)} do volume",
          hint: @helpers.brl(amount),
          tone: transaction_type == "income" ? :emerald : :rose
        }
      end
    end

    def expenses_by_status
      fetch(:expenses_by_status).map do |entry|
        amount = entry.fetch(:value)
        status = entry.fetch(:status)

        {
          label: @helpers.transaction_status_label(status),
          value: amount,
          meta: "#{percentage(amount, expense_total)} das despesas",
          hint: @helpers.brl(amount),
          tone: status_tone(status)
        }
      end
    end

    private

    def fetch(key)
      @data.fetch(key)
    end

    def timeline_bucket
      @period.in?(%w[week month]) ? :day : :month
    end

    def timeline_label(point)
      point.strftime(timeline_bucket == :day ? TIMELINE_DAY_FORMAT : TIMELINE_MONTH_FORMAT)
    end

    def percentage(value, total)
      return "0%" if total.to_d.zero?

      "#{((value.to_d / total.to_d) * 100).round}%"
    end

    def status_tone(status)
      case status
      when "paid", "received"
        :emerald
      when "pending"
        :amber
      when "canceled"
        :slate
      else
        :teal
      end
    end
  end
end
