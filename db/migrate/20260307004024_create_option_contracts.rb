class CreateOptionContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :option_contracts do |t|
      t.references :ticker
      t.string :option_type, null: false # put or call
      t.string  :symbol,        null: false, index: { unique: true }
      t.decimal :strike_price,  null: false, precision: 19, scale: 4
      t.date    :expires_on,    null: false
      t.integer :contract_size, default: 100
      t.string  :currency,      default: 'USD'

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
