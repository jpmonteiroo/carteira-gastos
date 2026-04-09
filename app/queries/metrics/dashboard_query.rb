module Metrics
  class DashboardQuery
    SECTIONS = [
      ::Metrics::Dashboard::SummaryQuery,
      ::Metrics::Dashboard::ExpenseTimelineQuery,
      ::Metrics::Dashboard::ExpensesByCategoryQuery,
      ::Metrics::Dashboard::AmountsByTypeQuery,
      ::Metrics::Dashboard::ExpensesByStatusQuery
    ].freeze

    def initialize(scope:, period:, date_range:)
      @scope = scope
      @period = period
      @date_range = date_range
    end

    def call
      SECTIONS.reduce({}) do |result, query|
        result.merge(query.call(scope: scoped_transactions, period: @period, date_range: @date_range))
      end
    end

    private

    def scoped_transactions
      @scoped_transactions ||= @scope.includes(:category)
    end
  end
end
