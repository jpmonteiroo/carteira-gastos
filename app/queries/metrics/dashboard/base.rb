module Metrics
  module Dashboard
    class Base
      def self.call(*args, **kwargs)
        new(*args, **kwargs).call
      end

      def initialize(scope:, period:, date_range:)
        @scope = scope
        @period = period
        @date_range = date_range
      end

      private

      attr_reader :scope, :period, :date_range

      def expenses
        @expenses ||= scope.expenses
      end
    end
  end
end
