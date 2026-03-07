class StocksService
  class << self

    def create_or_get_by_ticker(symbol)
      ticker = Ticker.find_by(symbol: symbol.upcase)
      
      return ticker if ticker.present?

      ticker_info = client.asset(symbol)

      ticker = Ticker.create!(
        symbol: symbol,
        name: ticker_info["name"],
        primary_exchange: ticker_info["exchange"]
      )

      ticker
    end

    # Fetches and upserts daily OHLCV bars for a ticker between start_date and end_date.
    # Returns the number of records upserted.
    def get_daily_prices(ticker, start_date, end_date)
      bars = client.bars(
        ticker.symbol,
        timeframe:  "1Day",
        start:      start_date.iso8601,
        end:        end_date.iso8601,
        adjustment: "raw",
        feed:       "iex"
      )

      rows = bars.map do |bar|
        timestamp = Time.parse(bar["t"])
        {
          ticker_id:   ticker.id,
          date:        timestamp.to_date,
          start_at:    timestamp,
          end_at:      timestamp.end_of_day,
          price_open:  bar["o"],
          price_high:  bar["h"],
          price_low:   bar["l"],
          price_close: bar["c"],
          volume:      bar["v"],
          vwap:        bar["vw"],
          num_trades:  bar["n"],
          created_at:  Time.current,
          updated_at:  Time.current
        }
      end

      return 0 if rows.empty?

      TickerDailyPrice.upsert_all(
        rows,
        unique_by: %i[ticker_id date],
        update_only: %i[start_at end_at price_open price_high price_low price_close volume vwap num_trades updated_at]
      )

      true
    end

    # Fetches and upserts minute OHLCV bars for a ticker between start_at and end_at.
    # Returns the number of records upserted.
    def get_minute_prices(ticker, start_at, end_at)
      bars = client.bars(
        ticker.symbol,
        timeframe:  "1Min",
        start:      start_at.iso8601,
        end:        end_at.iso8601,
        limit:      10_000,
        adjustment: "raw",
        feed:       "iex"
      )

      rows = bars.map do |bar|
        bar_start = Time.parse(bar["t"])
        {
          ticker_id:   ticker.id,
          date:        bar_start.to_date,
          start_at:    bar_start,
          end_at:      bar_start + 60.seconds,
          price_open:  bar["o"],
          price_high:  bar["h"],
          price_low:   bar["l"],
          price_close: bar["c"],
          volume:      bar["v"],
          vwap:        bar["vw"],
          num_trades:  bar["n"],
          created_at:  Time.current,
          updated_at:  Time.current
        }
      end

      return 0 if rows.empty?

      TickerMinutePrice.upsert_all(
        rows,
        unique_by: %i[ticker_id start_at],
        update_only: %i[end_at date price_open price_high price_low price_close volume vwap num_trades updated_at]
      )

      true
    end

    def get_news(symbol, start_from)
      ticker   = create_or_get_by_ticker(symbol)
      articles = client.news(symbol, start: start_from.iso8601)

      articles.each do |article|
        images = article.fetch("images", [])
        thumb  = images.find { |i| i["size"] == "thumb" }&.fetch("url", nil)
        large  = images.find { |i| i["size"] == "large" }&.fetch("url", nil)

        news = News.find_or_create_by!(article_url: article["url"]) do |n|
          n.headline     = article["headline"]
          n.author       = article["author"]
          n.source       = article["source"]
          n.summary      = article["summary"]
          n.thumb_url    = thumb
          n.large_url    = large
          n.published_at = Time.parse(article["created_at"])
        end

        news.add_tag(ticker)
      end

      true
    end

    def stream_news(symbols)
    end

    private

    def client
      @client ||= AlpacaClient.new
    end
  end
end
