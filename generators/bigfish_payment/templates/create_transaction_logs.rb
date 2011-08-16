class CreateBigfishPaymentTransactionLogs < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_transaction_logs do |t|
      t.references :bf_payment_transaction, :null => false
      t.text :result_code, :null => false
      t.text :response

      t.timestamps
    end

    add_index :bf_payment_transaction_logs, :bf_payment_transaction_id
  end

  def self.down
    drop_table :bf_payment_transaction_logs
  end

end
