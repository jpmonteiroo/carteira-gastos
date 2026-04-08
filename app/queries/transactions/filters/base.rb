module Transactions
  module Filters
    class Base
      def self.apply(scope, filters)
        new(scope, filters).apply
      end

      def initialize(scope, filters)
        @scope = scope
        @filters = filters
      end

      private

      attr_reader :scope, :filters
    end
  end
end
