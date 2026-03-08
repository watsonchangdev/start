class CreateTradeOptionDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :trade_option_details do |t|
      t.references :trade,            null: false
      t.references :option_contract,  null: false
      t.string :side_type,      null: false # buy or sell
      t.string :action_type,    null: false  # open / close
      t.integer :quantity,      null: false
      t.decimal :premium,       null: false, precision: 19, scale: 4

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
