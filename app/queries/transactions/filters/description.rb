module Transactions
  module Filters
    class Description < Base
      def apply
        return scope unless normalized_description.present?

        scope.where("transactions.description ILIKE ?", "%#{normalized_description}%")
      end

      private

      def normalized_description
        filters[:description].to_s.strip.presence
      end
    end
  end
end
