class CreateTradeStockDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :trade_stock_details do |t|
      t.references :trade, null: false
      t.string :side_type,    null: false # buy or sell
      t.decimal :quantity,    null: false, precision: 19, scale: 8
      t.decimal :price,       null: false, precision: 19, scale: 4

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
