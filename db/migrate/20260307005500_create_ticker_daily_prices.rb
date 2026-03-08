class CreateTickerDailyPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :ticker_daily_prices do |t|
      t.references :ticker
      t.decimal :price_low,   precision: 19, scale: 4
      t.decimal :price_high,  precision: 19, scale: 4
      t.decimal :price_open,  precision: 19, scale: 4
      t.decimal :price_close, precision: 19, scale: 4
      t.decimal :volume,      precision: 19, scale: 2
      t.integer :num_trades
      t.decimal :vwap,        precision: 19, scale: 4

      t.date :date
      t.datetime :start_at
      t.datetime :end_at

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :ticker_daily_prices, [ :ticker_id, :date ], unique: true
  end
end
