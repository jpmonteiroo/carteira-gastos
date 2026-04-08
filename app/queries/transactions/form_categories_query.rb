module Transactions
  class FormCategoriesQuery
    def initialize(user:, transaction_type:)
      @user = user
      @transaction_type = transaction_type.presence_in(Transaction::TYPES)
    end

    def filtered
      return ordered_categories unless @transaction_type.present?

      ordered_categories.select { |category| category.kind == @transaction_type }
    end

    def serialized
      ordered_categories.map do |category|
        {
          id: category.id,
          name: category.name,
          kind: category.kind
        }
      end
    end

    private

    def ordered_categories
      @ordered_categories ||= @user.categories.order(:kind, :name).to_a
    end
  end
end
