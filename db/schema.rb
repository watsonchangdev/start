# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_07_154729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "channel_bots", force: :cascade do |t|
    t.string "bot_type", null: false
    t.bigint "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["channel_id", "bot_type"], name: "index_channel_bots_on_channel_id_and_bot_type", unique: true
    t.index ["channel_id"], name: "index_channel_bots_on_channel_id"
  end

  create_table "channel_messages", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "message_type", null: false
    t.jsonb "metadata", default: {}
    t.bigint "sent_by_id", null: false
    t.string "sent_by_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["channel_id"], name: "index_channel_messages_on_channel_id"
    t.index ["sent_by_type", "sent_by_id"], name: "index_channel_messages_on_sent_by"
  end

  create_table "channel_users", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "username"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["channel_id", "user_id"], name: "index_channel_users_on_channel_id_and_user_id", unique: true
    t.index ["channel_id"], name: "index_channel_users_on_channel_id"
    t.index ["user_id"], name: "index_channel_users_on_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.string "channel_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["name"], name: "index_channels_on_name", unique: true
  end

  create_table "news", force: :cascade do |t|
    t.string "article_url"
    t.string "author"
    t.datetime "created_at", null: false
    t.string "headline"
    t.string "large_url"
    t.jsonb "metadata"
    t.datetime "published_at", null: false
    t.string "source"
    t.text "summary"
    t.string "thumb_url"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
  end

  create_table "option_contracts", force: :cascade do |t|
    t.integer "contract_size"
    t.datetime "created_at", null: false
    t.string "currency"
    t.date "expires_on"
    t.string "option_type", null: false
    t.float "strike_price"
    t.string "symbol", null: false
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["symbol"], name: "index_option_contracts_on_symbol", unique: true
    t.index ["ticker_id"], name: "index_option_contracts_on_ticker_id"
  end

  create_table "option_daily_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "end_at"
    t.integer "num_trades"
    t.bigint "option_contract_id"
    t.float "price_close"
    t.float "price_high"
    t.float "price_low"
    t.float "price_open"
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.float "volume"
    t.float "vwap"
    t.index ["option_contract_id", "date"], name: "index_option_daily_prices_on_option_contract_id_and_date", unique: true
    t.index ["option_contract_id"], name: "index_option_daily_prices_on_option_contract_id"
    t.index ["ticker_id"], name: "index_option_daily_prices_on_ticker_id"
  end

  create_table "option_minute_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "end_at"
    t.integer "num_trades"
    t.bigint "option_contract_id"
    t.float "price_close"
    t.float "price_high"
    t.float "price_low"
    t.float "price_open"
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.float "volume"
    t.float "vwap"
    t.index ["option_contract_id", "start_at"], name: "index_option_minute_prices_on_option_contract_id_and_start_at", unique: true
    t.index ["option_contract_id"], name: "index_option_minute_prices_on_option_contract_id"
    t.index ["ticker_id"], name: "index_option_minute_prices_on_ticker_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["source_type", "source_id", "taggable_type", "taggable_id"], name: "index_tags_uniqueness", unique: true
    t.index ["source_type", "source_id"], name: "index_tags_on_source"
    t.index ["taggable_type", "taggable_id"], name: "index_tags_on_taggable"
  end

  create_table "ticker_daily_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "end_at"
    t.integer "num_trades"
    t.float "price_close"
    t.float "price_high"
    t.float "price_low"
    t.float "price_open"
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.float "volume"
    t.float "vwap"
    t.index ["ticker_id", "date"], name: "index_ticker_daily_prices_on_ticker_id_and_date", unique: true
    t.index ["ticker_id"], name: "index_ticker_daily_prices_on_ticker_id"
  end

  create_table "ticker_minute_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "end_at"
    t.integer "num_trades"
    t.float "price_close"
    t.float "price_high"
    t.float "price_low"
    t.float "price_open"
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.float "volume"
    t.float "vwap"
    t.index ["ticker_id", "start_at"], name: "index_ticker_minute_prices_on_ticker_id_and_start_at", unique: true
    t.index ["ticker_id"], name: "index_ticker_minute_prices_on_ticker_id"
  end

  create_table "tickers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency"
    t.date "listed_on"
    t.string "name"
    t.string "primary_exchange", null: false
    t.string "sic_code"
    t.string "symbol", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "website"
    t.index ["symbol"], name: "index_tickers_on_symbol", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "channel_bots", "channels"
  add_foreign_key "channel_messages", "channels"
  add_foreign_key "channel_users", "channels"
  add_foreign_key "channel_users", "users"
  add_foreign_key "sessions", "users"
end
