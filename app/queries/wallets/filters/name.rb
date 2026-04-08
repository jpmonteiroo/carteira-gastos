module Wallets
  module Filters
    class Name < Base
      def apply
        return scope unless normalized_name.present?

        scope.where("wallets.name ILIKE ?", "%#{normalized_name}%")
      end

      private

      def normalized_name
        filters[:name].to_s.strip.presence
      end
    end
  end
end
