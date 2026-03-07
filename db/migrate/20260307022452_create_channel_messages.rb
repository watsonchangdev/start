class CreateChannelMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_messages do |t|
      t.references :channel, null: false, foreign_key: true
      t.references :sent_by, polymorphic: true, null: false

      t.text :content, null: false

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end
  end
end
