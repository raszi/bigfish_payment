class CreateBigfishPaymentCurrencies < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_currencies do |t|
      t.string :name, :null => false
      t.string :code, :null => false, :limit => 3

      t.timestamps
    end

    add_index :bf_payment_currencies, :code, :unique => true
  end

  def self.down
    drop_table :bf_payment_currencies
  end
end
