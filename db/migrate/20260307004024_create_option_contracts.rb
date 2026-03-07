class CreateOptionContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :option_contracts do |t|
      t.references :ticker
      t.string :option_type, null: false

      t.string :symbol, null: false, index: { unique: true }
      t.float :strike_price
      t.date :expires_on
      t.integer :contract_size
      t.string :currency

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
