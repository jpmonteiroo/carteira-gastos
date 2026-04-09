module Metrics
  module Dashboard
    class ExpenseTimelineQuery < Base
      def call
        {
          expense_timeline: timeline_points.map do |point|
            {
              point: point,
              value: grouped_amounts.fetch(timeline_group_key(point), 0).to_d
            }
          end
        }
      end

      private

      def grouped_amounts
        @grouped_amounts ||= if timeline_bucket == :day
                               expenses.group(:date).sum(:amount)
                             else
                               expenses.group(Transaction::MONTH_TRUNC_SQL).sum(:amount)
                             end
      end

      def timeline_bucket
        period.in?(%w[week month]) ? :day : :month
      end

      def timeline_points
        @timeline_points ||= if timeline_bucket == :day
                               (date_range.begin..date_range.end).to_a
                             else
                               month_points
                             end
      end

      def month_points
        points = []
        current_point = date_range.begin.beginning_of_month

        while current_point <= date_range.end
          points << current_point
          current_point = current_point.next_month
        end

        points
      end

      def timeline_group_key(point)
        timeline_bucket == :day ? point : point.beginning_of_month.beginning_of_day
      end
    end
  end
end
