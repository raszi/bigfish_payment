class CreateBigfishPaymentCurrencies < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_currencies do |t|
      t.string :name, :null => false
      t.string :code, :null => false, :limit => 3

      t.boolean :enabled, :default => false

      t.timestamps
    end

    add_index :bf_payment_currencies, :code, :unique => true
    add_index :bf_payment_currencies, :enabled

    say_with_time('Creating default Currencies') do
      BigfishPayment::Currency.create([
        {
          :name => 'Hungarian forint',
          :code => 'HUF',
          :enabled => true
        },
        {
          :name => 'Euro',
          :code => 'EUR',
          :enabled => true
        },
        {
          :name => 'United States Dollar',
          :code => 'USD',
          :enabled => true
        }
      ])
    end
  end

  def self.down
    drop_table :bf_payment_currencies
  end
end
