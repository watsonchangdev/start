class CreateNews < ActiveRecord::Migration[8.1]
  def change
    create_table :news do |t|
      t.string :headline
      t.string :author
      t.string :source
      t.text :summary

      t.string :thumb_url
      t.string :large_url
      t.string :article_url

      t.datetime :published_at, null: false
      t.string :api_reference_key
      t.jsonb :metadata, default: {}

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :news, :api_reference_key, unique: true
  end
end
