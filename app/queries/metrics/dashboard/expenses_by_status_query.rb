module Metrics
  module Dashboard
    class ExpensesByStatusQuery < Base
      def call
        totals = expenses.group(:status).sum(:amount)

        {
          expenses_by_status: Transaction::STATUSES.filter_map do |status|
            amount = totals[status]
            next if amount.blank?

            {
              status: status,
              value: amount.to_d
            }
          end
        }
      end
    end
  end
end
