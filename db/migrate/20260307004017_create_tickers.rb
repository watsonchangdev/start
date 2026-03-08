class CreateTickers < ActiveRecord::Migration[8.1]
  def change
    create_table :tickers do |t|
      t.string :primary_exchange, null: false
      t.string :symbol, null: false, index: { unique: true }

      t.string :name
      t.string :website
      t.date :listed_on
      t.string :sic_code
      t.string :currency, default: 'USD'

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
