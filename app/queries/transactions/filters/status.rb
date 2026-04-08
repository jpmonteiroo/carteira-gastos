module Transactions
  module Filters
    class Status < Base
      def apply
        return scope unless normalized_status.present?

        scope.where(status: normalized_status)
      end

      private

      def normalized_status
        filters[:status].presence_in(Transaction::STATUSES)
      end
    end
  end
end
