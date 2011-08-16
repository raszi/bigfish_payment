class CreateBigfishPaymentTransactions < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_transactions do |t|
      t.integer :amount, :null => false

      #t.references :user, :null => false

      t.references :bf_payment_currency, :null => false
      t.references :bf_payment_provider, :null => false

      t.integer :state, :default => 0, :null => false

      t.string :transaction_id, :limit => 32

      t.timestamps
    end

    add_index :bf_payment_transactions, :bf_payment_currency_id
    add_index :bf_payment_transactions, :bf_payment_provider_id
    add_index :bf_payment_transactions, :transaction_id, :unique => true
  end

  def self.down
    drop_table :bf_payment_transactions
  end
end
