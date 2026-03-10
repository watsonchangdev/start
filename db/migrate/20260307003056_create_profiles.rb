class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :username, null: false
      t.string :first_name, null: true
      t.string :last_name, null: true
      t.string :timezone, null: true
      t.jsonb :preferences, default: {}
      t.jsonb :metadata, default: {}

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :profiles, :username, unique: true
  end
end
