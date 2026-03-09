# frozen_string_literal: true

# Idempotent seed file. Safe to run multiple times.

puts "==> Seeding database..."

# ============================================================
# User
# ============================================================

user = User.find_or_create_by!(email_address: "user@email.com") do |u|
  u.password = "password"
end

puts "    User: #{user.email_address}"

# ============================================================
# Tickers
# ============================================================

aapl = Ticker.find_or_create_by!(symbol: "AAPL") do |t|
  t.name             = "Apple Inc."
  t.primary_exchange = "NASDAQ"
end

nvda = Ticker.find_or_create_by!(symbol: "NVDA") do |t|
  t.name             = "NVIDIA Corporation"
  t.primary_exchange = "NASDAQ"
end

puts "    Tickers: #{[ aapl, nvda ].map(&:symbol).join(', ')}"

# ============================================================
# Channels (via TickerChannelService)
# ============================================================

[ aapl, nvda ].each do |ticker|
  next if Channel.exists?(name: ticker.symbol)

  # Stub StocksService so the service doesn't hit Alpaca
  allow_existing = ->(sym, **) { Ticker.find_by!(symbol: sym.upcase) }
  StocksService.define_singleton_method(:create_or_get_by_ticker, allow_existing)

  ChannelService.create_ticker_channel(ticker.symbol, participant_users: [ user ])
  puts "    Channel: ##{ticker.symbol}"
end

# ============================================================
# Daily prices — 6 months via StocksService
# ============================================================

[ aapl, nvda ].each do |ticker|
  next if TickerDailyPrice.where(ticker: ticker).exists?

  StocksService.get_daily_prices(ticker, 6.months.ago.to_date, Date.today)
  count = TickerDailyPrice.where(ticker: ticker).count
  puts "    Daily prices: #{ticker.symbol} (#{count} bars)"
end

# ============================================================
# Option contracts
# ============================================================

aapl_call = OptionContract.find_or_create_by!(symbol: "AAPL250620C00190000") do |c|
  c.ticker        = aapl
  c.option_type   = "call"
  c.strike_price  = 190.00
  c.expires_on    = Date.new(2025, 6, 20)
  c.contract_size = 100
  c.currency      = "USD"
end

aapl_put = OptionContract.find_or_create_by!(symbol: "AAPL250620P00175000") do |c|
  c.ticker        = aapl
  c.option_type   = "put"
  c.strike_price  = 175.00
  c.expires_on    = Date.new(2025, 6, 20)
  c.contract_size = 100
  c.currency      = "USD"
end

nvda_call = OptionContract.find_or_create_by!(symbol: "NVDA250620C00900000") do |c|
  c.ticker        = nvda
  c.option_type   = "call"
  c.strike_price  = 900.00
  c.expires_on    = Date.new(2025, 6, 20)
  c.contract_size = 100
  c.currency      = "USD"
end

puts "    Option contracts: #{[ aapl_call, aapl_put, nvda_call ].map(&:symbol).join(', ')}"

# ============================================================
# Trades — 5 stock, 5 option
# ============================================================

unless Trade.where(user: user).exists?
  # --- Stock trades ---

  [
    { ticker: aapl, side: "buy",  qty: 50,  price: 178.42, executed_at: 45.days.ago },
    { ticker: aapl, side: "buy",  qty: 25,  price: 182.10, executed_at: 30.days.ago },
    { ticker: aapl, side: "sell", qty: 30,  price: 191.75, executed_at: 15.days.ago },
    { ticker: nvda, side: "buy",  qty: 10,  price: 842.50, executed_at: 40.days.ago },
    { ticker: nvda, side: "sell", qty: 5,   price: 903.20, executed_at: 10.days.ago }
  ].each do |t|
    total = (t[:qty] * t[:price]).round(4)

    trade = Trade.create!(
      user:         user,
      ticker:       t[:ticker],
      trade_type:   Enums::Trades::TradeType::Stock.serialize,
      total_amount: total,
      commission:   0.00,
      exchange_fee: 0.00,
      net_total:    total,
      executed_at:  t[:executed_at]
    )

    TradeStockDetail.create!(
      trade:     trade,
      side_type: t[:side],
      quantity:  t[:qty],
      price:     t[:price]
    )
  end

  # --- Option trades ---

  [
    { contract: aapl_call, ticker: aapl, side: "buy",  action: "open",  qty: 2, premium: 3.40, executed_at: 35.days.ago },
    { contract: aapl_call, ticker: aapl, side: "sell", action: "close", qty: 2, premium: 6.80, executed_at: 12.days.ago },
    { contract: aapl_put,  ticker: aapl, side: "buy",  action: "open",  qty: 3, premium: 2.15, executed_at: 28.days.ago },
    { contract: nvda_call, ticker: nvda, side: "buy",  action: "open",  qty: 1, premium: 18.50, executed_at: 20.days.ago },
    { contract: nvda_call, ticker: nvda, side: "sell", action: "close", qty: 1, premium: 34.20, executed_at: 5.days.ago }
  ].each do |t|
    total = (t[:premium] * t[:qty] * 100).round(4)

    trade = Trade.create!(
      user:         user,
      ticker:       t[:ticker],
      trade_type:   Enums::Trades::TradeType::Option.serialize,
      total_amount: total,
      commission:   0.65,
      exchange_fee: 0.10,
      net_total:    (total + 0.75).round(4),
      executed_at:  t[:executed_at]
    )

    TradeOptionDetail.create!(
      trade:           trade,
      option_contract: t[:contract],
      side_type:       t[:side],
      action_type:     t[:action],
      quantity:        t[:qty],
      premium:         t[:premium]
    )
  end

  puts "    Trades: 5 stock + 5 option"
end

puts "==> Done."
