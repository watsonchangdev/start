class CreateChannelBots < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_bots do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :bot_type, null: false

      t.string :username

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :channel_bots, [ :channel_id, :bot_type ], unique: true
  end
end
