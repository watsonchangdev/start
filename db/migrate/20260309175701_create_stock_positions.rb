class CreateStockPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_positions do |t|
      t.references :user,   null: false
      t.references :ticker, null: false
      t.string  :status,             null: false, default: "open"
      t.decimal :quantity,           null: false, precision: 19, scale: 8
      t.decimal :average_cost_basis, null: false, precision: 19, scale: 4
      t.decimal :realized_pnl,       null: false, precision: 19, scale: 4, default: 0

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :stock_positions, :uuid, unique: true
    add_index :stock_positions, [ :user_id, :ticker_id ], unique: true
  end
end
