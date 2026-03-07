class CreateOptionDailyPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :option_daily_prices do |t|
      t.references :ticker
      t.references :option_contract
      t.float :price_low
      t.float :price_high
      t.float :price_open
      t.float :price_close
      t.float :volume
      t.integer :num_trades
      t.float :vwap

      t.date :date
      t.datetime :start_at
      t.datetime :end_at

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :option_daily_prices, [:option_contract_id, :date], unique: true
  end
end
