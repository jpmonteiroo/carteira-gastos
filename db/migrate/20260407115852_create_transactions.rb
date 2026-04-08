class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.date :date
      t.decimal :amount, precision: 12, scale: 2
      t.string :transaction_type
      t.string :status
      t.text :description

      t.timestamps
    end
  end
end
