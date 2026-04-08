module Categories
  module Filters
    class Kind < Base
      def apply
        return scope unless normalized_kind.present?

        scope.where(kind: normalized_kind)
      end

      private

      def normalized_kind
        filters[:kind].presence_in(Category::KINDS)
      end
    end
  end
end
