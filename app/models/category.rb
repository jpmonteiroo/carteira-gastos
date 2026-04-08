class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :nullify

  KINDS = %w[income expense].freeze

  validates :name, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }
end
