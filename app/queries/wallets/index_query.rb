module Wallets
  class IndexQuery
    FILTERS = [
      ::Wallets::Filters::Name
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
      @user.wallets
        .left_joins(:transactions)
        .select("wallets.*, COUNT(transactions.id) AS transactions_count, MAX(transactions.date) AS last_transaction_date")
        .group("wallets.id")
        .order(:name)
    end

    def apply_filters(scope)
      FILTERS.reduce(scope) do |current_scope, filter|
        filter.apply(current_scope, @filters)
      end
    end
  end
end
