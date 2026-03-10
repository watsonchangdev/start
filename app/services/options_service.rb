class OptionsService
  class << self
    # Finds or creates an OptionContract by OCC symbol, fetching metadata from Alpaca if needed.
    # Returns the OptionContract record.
    def create_or_get_by_occ_symbol(occ_symbol)
      contract = OptionContract.find_by(symbol: occ_symbol)
      return contract if contract.present?

      data   = client.option_contract(occ_symbol)
      ticker = StocksService.create_or_get_by_ticker(data["underlying_symbol"])

      OptionContract.create!(
        symbol:        data["symbol"],
        ticker:        ticker,
        option_type:   data["type"],
        strike_price:  data["strike_price"],
        expires_on:    Date.parse(data["expiration_date"]),
        contract_size: data["multiplier"].to_i,
        currency:      data.fetch("currency", "USD")
      )
    end

    # Fetches and upserts minute OHLCV bars for an option contract between start_at and end_at.
    # Returns true on success, false if no bars were returned.
    def get_minute_prices(occ_symbol, start_at, end_at)
      option_contract = create_or_get_by_occ_symbol(occ_symbol)

      bars = client.option_bars(
        occ_symbol,
        timeframe: "1Min",
        start:     start_at.iso8601,
        end:       end_at.iso8601,
        limit:     10_000
      )

      return false if bars.empty?

      rows = bars.map do |bar|
        bar_start = Time.parse(bar["t"])
        {
          option_contract_id: option_contract.id,
          ticker_id:          option_contract.ticker_id,
          date:               bar_start.to_date,
          start_at:           bar_start,
          end_at:             bar_start + 60.seconds,
          price_open:         bar["o"],
          price_high:         bar["h"],
          price_low:          bar["l"],
          price_close:        bar["c"],
          volume:             bar["v"],
          vwap:               bar["vw"],
          num_trades:         bar["n"],
          created_at:         Time.current,
          updated_at:         Time.current
        }
      end

      OptionMinutePrice.insert_all(rows, unique_by: %i[option_contract_id start_at])

      true
    end

    # Fetches and upserts daily OHLCV bars for an option contract between start_date and end_date.
    # Returns true on success, false if no bars were returned.
    def get_daily_prices(occ_symbol, start_date, end_date)
      option_contract = create_or_get_by_occ_symbol(occ_symbol)

      bars = client.option_bars(
        occ_symbol,
        timeframe: "1Day",
        start:     start_date.iso8601,
        end:       end_date.iso8601
      )

      return false if bars.empty?

      bars.each do |bar|
        date = Date.parse(bar["t"])

        OptionDailyPrice.find_or_create_by!(option_contract: option_contract, date: date) do |r|
          r.ticker_id   = option_contract.ticker_id
          r.start_at    = ActiveSupport::TimeZone["Eastern Time (US & Canada)"].local(date.year, date.month, date.day, 9, 30)
          r.end_at      = ActiveSupport::TimeZone["Eastern Time (US & Canada)"].local(date.year, date.month, date.day, 16, 0)
          r.price_open  = bar["o"]
          r.price_high  = bar["h"]
          r.price_low   = bar["l"]
          r.price_close = bar["c"]
          r.volume      = bar["v"]
          r.vwap        = bar["vw"]
          r.num_trades  = bar["n"]
        end
      end

      true
    end

    private

    def client
      @client ||= AlpacaClient.new
    end
  end
end
