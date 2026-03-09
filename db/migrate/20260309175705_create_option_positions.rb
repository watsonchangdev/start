class CreateOptionPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :option_positions do |t|
      t.references :user,            null: false
      t.references :ticker,          null: false
      t.references :option_contract, null: false
      t.string  :status,             null: false, default: "open"
      t.string  :side,               null: false
      t.integer :quantity,           null: false
      t.decimal :average_cost_basis, null: false, precision: 19, scale: 4
      t.decimal :realized_pnl,       null: false, precision: 19, scale: 4, default: 0

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :option_positions, :uuid, unique: true
    add_index :option_positions, [ :user_id, :option_contract_id ], unique: true
  end
end
