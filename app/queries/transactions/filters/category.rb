module Transactions
  module Filters
    class Category < Base
      def apply
        return scope unless normalized_category_id.present?

        scope.where(category_id: normalized_category_id)
      end

      private

      def normalized_category_id
        filters[:category_id].presence
      end
    end
  end
end
