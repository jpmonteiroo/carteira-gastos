module Transactions
  module Filters
    class DatePeriod < Base
      def apply
        return scope unless normalized_period.present?

        scope.where(date: date_range)
      end

      private

      def normalized_period
        filters[:period].to_s.presence_in(::Transactions::IndexQuery::PERIODS)
      end

      def date_range
        case normalized_period
        when "week"
          current_date.beginning_of_week..current_date.end_of_week
        when "month"
          current_date.beginning_of_month..current_date.end_of_month
        when "quarter"
          current_date.beginning_of_quarter..current_date.end_of_quarter
        when "semester"
          semester_start..semester_end
        when "year"
          current_date.beginning_of_year..current_date.end_of_year
        end
      end

      def current_date
        Date.current
      end

      def semester_start
        month = current_date.month <= 6 ? 1 : 7
        Date.new(current_date.year, month, 1)
      end

      def semester_end
        semester_start.advance(months: 6).prev_day
      end
    end
  end
end
