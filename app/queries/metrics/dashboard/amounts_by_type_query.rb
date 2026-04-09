module Metrics
  module Dashboard
    class AmountsByTypeQuery < Base
      def call
        totals = scope.group(:transaction_type).sum(:amount)

        {
          amounts_by_type: Transaction::TYPES.filter_map do |transaction_type|
            amount = totals[transaction_type]
            next if amount.blank?

            {
              transaction_type: transaction_type,
              value: amount.to_d
            }
          end
        }
      end
    end
  end
end
