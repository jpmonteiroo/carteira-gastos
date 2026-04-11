module Transactions
  class DateRange
    def self.resolve(period:, reference_date: Date.current)
      new(period:, reference_date:).call
    end

    def initialize(period:, reference_date: Date.current)
      @period = period.to_s.presence_in(::Constants::PERIODS) || "month"
      @reference_date = reference_date.to_date
    end

    def call
      case @period
      when "week"
        @reference_date.beginning_of_week..@reference_date.end_of_week
      when "month"
        @reference_date.beginning_of_month..@reference_date.end_of_month
      when "quarter"
        @reference_date.beginning_of_quarter..@reference_date.end_of_quarter
      when "semester"
        semester_start..semester_end
      when "year"
        @reference_date.beginning_of_year..@reference_date.end_of_year
      end
    end

    private

    def semester_start
      month = @reference_date.month <= 6 ? 1 : 7
      Date.new(@reference_date.year, month, 1)
    end

    def semester_end
      semester_start.advance(months: 6).prev_day
    end
  end
end
