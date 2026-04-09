module Metrics
  module Dashboard
    class SummaryQuery < Base
      def call
        income_total = scope.incomes.sum(:amount).to_d
        expense_total = expenses.sum(:amount).to_d

        {
          income_total: income_total,
          expense_total: expense_total,
          balance: income_total - expense_total,
          transaction_count: scope.count,
          average_expense: expenses.average(:amount)&.to_d || 0.to_d,
          largest_expense: expenses.maximum(:amount)&.to_d || 0.to_d
        }
      end
    end
  end
end
