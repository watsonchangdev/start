class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :source,  polymorphic: true, null: false
      t.references :taggable, polymorphic: true, null: false

      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_index :tags, [ :source_type, :source_id, :taggable_type, :taggable_id ], unique: true, name: "index_tags_uniqueness"
  end
end
