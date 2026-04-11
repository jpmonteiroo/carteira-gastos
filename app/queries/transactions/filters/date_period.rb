module Transactions
  module Filters
    class DatePeriod < Base
      def apply
        return scope unless normalized_period.present?

        scope.where(date: date_range)
      end

      private

      def normalized_period
        filters[:period].to_s.presence_in(::Constants::PERIODS)
      end

      def date_range
        ::Transactions::DateRange.resolve(period: normalized_period, reference_date: Date.current)
      end
    end
  end
end
