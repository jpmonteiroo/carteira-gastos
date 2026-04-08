module Categories
  class IndexQuery
    FILTERS = [
      ::Categories::Filters::Kind
    ].freeze

    def initialize(user:, filters: {})
      @user = user
      @filters = filters
    end

    def call
      apply_filters(base_scope).to_a
    end

    private

    def base_scope
      @user.categories
        .left_joins(:transactions)
        .select("categories.*, COUNT(transactions.id) AS transactions_count")
        .group("categories.id")
        .order(:kind, :name)
    end

    def apply_filters(scope)
      FILTERS.reduce(scope) do |current_scope, filter|
        filter.apply(current_scope, @filters)
      end
    end
  end
end
