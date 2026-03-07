class SyncService
  class << self
    def sync_historical
      start_date = 2.years.ago.to_date
      end_date   = Date.today

      Ticker.find_each do |ticker|
        StocksService.get_daily_prices(ticker, start_date, end_date)
      end
    end

    def sync_news(symbols)
      symbols.each do |symbol|
        StocksService.get_news(symbol, 24.hours.ago)
      end
    end

    def stream_tickers
    end

    def stream_news
    end
  end
end
