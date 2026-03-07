class CreateChannelUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_users do |t|
      t.references :channel, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :username
      
      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :channel_users, [:channel_id, :user_id], unique: true
  end
end
