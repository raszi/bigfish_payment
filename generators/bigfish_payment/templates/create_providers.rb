class CreateBigfishPaymentProviders < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_providers do |t|
      t.string :name, :null => false
      t.text :description

      t.string :code, :null => false

      t.boolean :enabled, :default => false

      t.timestamps
    end

    add_index :bf_payment_providers, :code, :unique => true
    add_index :bf_payment_providers, :enabled

    say_with_time('Creating default Providers') do
      BigfishPayment::Provider.create([
        {
          :name => 'Abaqoos',
          :code => 'Abaqoos',
          :enabled => true
        },
        {
          :name => 'CIB',
          :code => 'CIB',
          :enabled => true
        },
        {
          :name => 'Escalion',
          :code => 'Escalion',
          :enabled => true
        },
        {
          :name => 'KHB',
          :code => 'KHB',
          :enabled => true
        },
        {
          :name => 'MPP',
          :code => 'MPP',
          :enabled => true
        },
        {
          :name => 'OTP',
          :code => 'OTP',
          :enabled => true
        },
        {
          :name => 'PayPal',
          :code => 'PayPal',
          :enabled => true
        },
        {
          :name => 'SMS',
          :code => 'SMS',
          :enabled => true
        }
      ])
    end
  end

  def self.down
    drop_table :bf_payment_providers
  end
end
