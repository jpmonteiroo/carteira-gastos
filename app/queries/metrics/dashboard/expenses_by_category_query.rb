module Metrics
  module Dashboard
    class ExpensesByCategoryQuery < Base
      LIMIT = 6

      def call
        {
          expenses_by_category: expenses
            .joins(:category)
            .group("categories.name")
            .sum(:amount)
            .sort_by { |_name, total| -total }
            .first(LIMIT)
            .map do |name, total|
              {
                label: name,
                value: total.to_d
              }
            end
        }
      end
    end
  end
end
