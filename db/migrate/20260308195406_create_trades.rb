class CreateTrades < ActiveRecord::Migration[8.1]
  def change
    create_table :trades do |t|
      t.references :user,   null: false
      t.references :ticker, null: false
      t.string  :trade_type,  null: false # stock or option
      t.decimal :total_amount, null: false, precision: 19, scale: 4
      t.decimal :commission,   default: 0,  precision: 19, scale: 4
      t.decimal :exchange_fee, default: 0, precision: 19, scale: 4
      t.decimal :net_total,    default: 0, precision: 19, scale: 4
      t.datetime :executed_at, null: false

      t.string :api_reference_key, index: { unique: true }
      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    # All trades for a user on a specific ticker (most common query)
    add_index :trades, [ :user_id, :ticker_id ]
  end
end
