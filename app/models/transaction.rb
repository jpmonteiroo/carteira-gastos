class Transaction < ApplicationRecord
  MONTH_TRUNC_SQL = Arel.sql("DATE_TRUNC('month', date)")

  belongs_to :user
  belongs_to :wallet
  belongs_to :category

  TYPES = %w[income expense].freeze
  STATUSES = %w[pending paid received canceled].freeze

  validates :date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true, inclusion: { in: TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  validate :category_kind_matches_transaction_type

  scope :incomes, -> { where(transaction_type: "income") }
  scope :expenses, -> { where(transaction_type: "expense") }
  scope :for_year, ->(year) { where(date: Date.new(year).beginning_of_year..Date.new(year).end_of_year) }
  scope :for_month, ->(year, month) do
    start_date = Date.new(year, month, 1)
    where(date: start_date.beginning_of_month..start_date.end_of_month)
  end

  def self.group_by_month_data(year)
    where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
      .group(MONTH_TRUNC_SQL)
      .order(MONTH_TRUNC_SQL)
      .sum(:amount)
  end

  private

  def category_kind_matches_transaction_type
    return if category.blank? || transaction_type.blank?
    return if category.kind == transaction_type

    errors.add(:category, "deve ser do mesmo tipo da transação")
  end
end
