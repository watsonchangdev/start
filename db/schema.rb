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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_005840) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  add_foreign_key "sessions", "users"
end
