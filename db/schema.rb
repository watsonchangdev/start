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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_175705) do
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
    t.bigint "sent_by_id"
    t.string "sent_by_type"
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

  create_table "event_store_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "metadata"
    t.datetime "valid_at"
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
    t.index ["valid_at"], name: "index_event_store_events_on_valid_at"
  end

  create_table "event_store_events_in_streams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.integer "position"
    t.string "stream", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_in_streams_on_event_id"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "news", force: :cascade do |t|
    t.string "api_reference_key"
    t.string "article_url"
    t.string "author"
    t.datetime "created_at", null: false
    t.string "headline"
    t.string "large_url"
    t.jsonb "metadata", default: {}
    t.datetime "published_at", null: false
    t.string "source"
    t.text "summary"
    t.string "thumb_url"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["api_reference_key"], name: "index_news_on_api_reference_key", unique: true
  end

  create_table "option_contracts", force: :cascade do |t|
    t.integer "contract_size", default: 100
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.date "expires_on", null: false
    t.string "option_type", null: false
    t.decimal "strike_price", precision: 19, scale: 4, null: false
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
    t.decimal "price_close", precision: 19, scale: 4
    t.decimal "price_high", precision: 19, scale: 4
    t.decimal "price_low", precision: 19, scale: 4
    t.decimal "price_open", precision: 19, scale: 4
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "volume", precision: 19, scale: 2
    t.decimal "vwap", precision: 19, scale: 4
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
    t.decimal "price_close", precision: 19, scale: 4
    t.decimal "price_high", precision: 19, scale: 4
    t.decimal "price_low", precision: 19, scale: 4
    t.decimal "price_open", precision: 19, scale: 4
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "volume", precision: 19, scale: 2
    t.decimal "vwap", precision: 19, scale: 4
    t.index ["option_contract_id", "start_at"], name: "index_option_minute_prices_on_option_contract_id_and_start_at", unique: true
    t.index ["option_contract_id"], name: "index_option_minute_prices_on_option_contract_id"
    t.index ["ticker_id"], name: "index_option_minute_prices_on_ticker_id"
  end

  create_table "option_positions", force: :cascade do |t|
    t.decimal "average_cost_basis", precision: 19, scale: 4, null: false
    t.datetime "created_at", null: false
    t.bigint "option_contract_id", null: false
    t.integer "quantity", null: false
    t.decimal "realized_pnl", precision: 19, scale: 4, default: "0.0", null: false
    t.string "side", null: false
    t.string "status", default: "open", null: false
    t.bigint "ticker_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["option_contract_id"], name: "index_option_positions_on_option_contract_id"
    t.index ["ticker_id"], name: "index_option_positions_on_ticker_id"
    t.index ["user_id", "option_contract_id", "side"], name: "idx_on_user_id_option_contract_id_side_7d022fb9df", unique: true
    t.index ["user_id"], name: "index_option_positions_on_user_id"
    t.index ["uuid"], name: "index_option_positions_on_uuid", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stock_positions", force: :cascade do |t|
    t.decimal "average_cost_basis", precision: 19, scale: 4, null: false
    t.datetime "created_at", null: false
    t.decimal "quantity", precision: 19, scale: 8, null: false
    t.decimal "realized_pnl", precision: 19, scale: 4, default: "0.0", null: false
    t.string "status", default: "open", null: false
    t.bigint "ticker_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["ticker_id"], name: "index_stock_positions_on_ticker_id"
    t.index ["user_id", "ticker_id"], name: "index_stock_positions_on_user_id_and_ticker_id", unique: true
    t.index ["user_id"], name: "index_stock_positions_on_user_id"
    t.index ["uuid"], name: "index_stock_positions_on_uuid", unique: true
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
    t.decimal "price_close", precision: 19, scale: 4
    t.decimal "price_high", precision: 19, scale: 4
    t.decimal "price_low", precision: 19, scale: 4
    t.decimal "price_open", precision: 19, scale: 4
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "volume", precision: 19, scale: 2
    t.decimal "vwap", precision: 19, scale: 4
    t.index ["ticker_id", "date"], name: "index_ticker_daily_prices_on_ticker_id_and_date", unique: true
    t.index ["ticker_id"], name: "index_ticker_daily_prices_on_ticker_id"
  end

  create_table "ticker_minute_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.datetime "end_at"
    t.integer "num_trades"
    t.decimal "price_close", precision: 19, scale: 4
    t.decimal "price_high", precision: 19, scale: 4
    t.decimal "price_low", precision: 19, scale: 4
    t.decimal "price_open", precision: 19, scale: 4
    t.datetime "start_at"
    t.bigint "ticker_id"
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "volume", precision: 19, scale: 2
    t.decimal "vwap", precision: 19, scale: 4
    t.index ["ticker_id", "start_at"], name: "index_ticker_minute_prices_on_ticker_id_and_start_at", unique: true
    t.index ["ticker_id"], name: "index_ticker_minute_prices_on_ticker_id"
  end

  create_table "tickers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
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

  create_table "trade_option_details", force: :cascade do |t|
    t.string "action_type", null: false
    t.datetime "created_at", null: false
    t.bigint "option_contract_id", null: false
    t.decimal "premium", precision: 19, scale: 4, null: false
    t.integer "quantity", null: false
    t.string "side_type", null: false
    t.bigint "trade_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["option_contract_id"], name: "index_trade_option_details_on_option_contract_id"
    t.index ["trade_id"], name: "index_trade_option_details_on_trade_id"
  end

  create_table "trade_stock_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "price", precision: 19, scale: 4, null: false
    t.decimal "quantity", precision: 19, scale: 8, null: false
    t.string "side_type", null: false
    t.bigint "trade_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["trade_id"], name: "index_trade_stock_details_on_trade_id"
  end

  create_table "trades", force: :cascade do |t|
    t.string "api_reference_key"
    t.decimal "commission", precision: 19, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.decimal "exchange_fee", precision: 19, scale: 4, default: "0.0"
    t.datetime "executed_at", null: false
    t.decimal "net_total", precision: 19, scale: 4, default: "0.0"
    t.bigint "ticker_id", null: false
    t.decimal "total_amount", precision: 19, scale: 4, null: false
    t.string "trade_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["api_reference_key"], name: "index_trades_on_api_reference_key", unique: true
    t.index ["ticker_id"], name: "index_trades_on_ticker_id"
    t.index ["user_id", "ticker_id"], name: "index_trades_on_user_id_and_ticker_id"
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "channel_bots", "channels"
  add_foreign_key "channel_messages", "channels"
  add_foreign_key "channel_users", "channels"
  add_foreign_key "channel_users", "users"
  add_foreign_key "event_store_events_in_streams", "event_store_events", column: "event_id", primary_key: "event_id"
  add_foreign_key "sessions", "users"
end
