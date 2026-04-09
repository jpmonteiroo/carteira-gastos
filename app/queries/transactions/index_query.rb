module Transactions
  class IndexQuery
    PERIODS = ::Transactions::DateRange::PERIODS
    SORT_COLUMNS = {
      "category" => "LOWER(categories.name)",
      "description" => "LOWER(COALESCE(transactions.description, ''))",
      "date" => "transactions.date",
      "status" => "LOWER(transactions.status)",
      "amount" => "transactions.amount"
    }.freeze
    DIRECTIONS = %w[asc desc].freeze
    DEFAULT_SORT = "date"
    DEFAULT_DIRECTION = "desc"
    FILTERS = [
      ::Transactions::Filters::DatePeriod,
      ::Transactions::Filters::Category,
      ::Transactions::Filters::Description,
      ::Transactions::Filters::Status
    ].freeze

    attr_reader :selected_sort, :selected_direction

    def initialize(scope:, filters: {}, sort: nil, direction: nil)
      @scope = scope
      @filters = filters
      @selected_sort = normalize_sort(sort)
      @selected_direction = normalize_direction(direction)
    end

    def call
      apply_sorting(apply_filters(base_scope))
    end

    private

    def base_scope
      @scope.includes(:category).joins(:category)
    end

    def apply_filters(scope)
      FILTERS.reduce(scope) do |current_scope, filter|
        filter.apply(current_scope, @filters)
      end
    end

    def apply_sorting(scope)
      scope.order(Arel.sql(primary_sort_clause)).order(secondary_sorting)
    end

    def primary_sort_clause
      "#{SORT_COLUMNS.fetch(selected_sort)} #{selected_direction.upcase}"
    end

    def secondary_sorting
      return { id: selected_direction.to_sym } if selected_sort == "date"

      { date: :desc, id: :desc }
    end

    def normalize_sort(sort)
      sort.to_s.presence_in(SORT_COLUMNS.keys) || DEFAULT_SORT
    end

    def normalize_direction(direction)
      direction.to_s.downcase.presence_in(DIRECTIONS) || DEFAULT_DIRECTION
    end
  end
end
