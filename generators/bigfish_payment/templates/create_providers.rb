class CreateBigfishPaymentProviders < ActiveRecord::Migration
  def self.up
    create_table :bf_payment_providers do |t|
      t.string :name, :null => false
      t.text :description, :null => false

      t.string :code, :null => false

      t.timestamps
    end

    add_index :bf_payment_providers, :code, :unique => true
  end

  def self.down
    drop_table :bf_payment_providers
  end
end
