require "test_helper"

class StocksServiceTest < ActiveSupport::TestCase
  setup do
    @mock_client = build_mock_client
    AlpacaClient.stub(:new, @mock_client) { StocksService.instance_variable_set(:@client, @mock_client) }
  end

  teardown do
    StocksService.instance_variable_set(:@client, nil)
  end

  # --- create_or_get_by_ticker ---

  test "create_or_get_by_ticker returns existing ticker without calling the API" do
    ticker = tickers(:aapl)
    api_called = false
    @mock_client.define_singleton_method(:asset) { |*| api_called = true; {} }

    result = StocksService.create_or_get_by_ticker("AAPL")

    assert_equal ticker, result
    assert_not api_called
  end

  test "create_or_get_by_ticker creates a new ticker from the API when not found" do
    @mock_client.define_singleton_method(:asset) do |_|
      { "name" => "Meta Platforms Inc.", "exchange" => "NASDAQ" }
    end

    assert_difference "Ticker.count", 1 do
      result = StocksService.create_or_get_by_ticker("META")
      assert_equal "META", result.symbol
      assert_equal "Meta Platforms Inc.", result.name
      assert_equal "NASDAQ", result.primary_exchange
    end
  end

  # --- get_daily_prices ---

  test "get_daily_prices returns 0 when API returns no bars" do
    ticker = tickers(:aapl)
    @mock_client.define_singleton_method(:bars) { |*| [] }

    result = StocksService.get_daily_prices(ticker, Date.new(2026, 1, 1), Date.new(2026, 1, 31))

    assert_equal 0, result
    assert_equal 0, TickerDailyPrice.where(ticker: ticker).count
  end

  test "get_daily_prices upserts bars and returns true" do
    ticker = tickers(:aapl)
    @mock_client.define_singleton_method(:bars) do |*|
      [ { "t" => "2026-01-02T00:00:00Z", "o" => 150.0, "h" => 155.0, "l" => 149.0, "c" => 153.0, "v" => 1_000_000, "vw" => 152.0, "n" => 5000 } ]
    end

    result = StocksService.get_daily_prices(ticker, Date.new(2026, 1, 1), Date.new(2026, 1, 31))

    assert result
    price = TickerDailyPrice.find_by(ticker: ticker, date: Date.new(2026, 1, 2))
    assert price
    assert_equal 150.0, price.price_open
    assert_equal 153.0, price.price_close
    assert_equal 152.0, price.vwap
  end

  test "get_daily_prices is idempotent on repeated calls" do
    ticker = tickers(:aapl)
    bar = { "t" => "2026-01-02T00:00:00Z", "o" => 150.0, "h" => 155.0, "l" => 149.0, "c" => 153.0, "v" => 1_000_000, "vw" => 152.0, "n" => 5000 }
    @mock_client.define_singleton_method(:bars) { |*| [ bar ] }

    StocksService.get_daily_prices(ticker, Date.new(2026, 1, 1), Date.new(2026, 1, 31))
    StocksService.get_daily_prices(ticker, Date.new(2026, 1, 1), Date.new(2026, 1, 31))

    assert_equal 1, TickerDailyPrice.where(ticker: ticker).count
  end

  # --- get_minute_prices ---

  test "get_minute_prices returns 0 when API returns no bars" do
    ticker = tickers(:aapl)
    @mock_client.define_singleton_method(:bars) { |*| [] }

    start_at = Time.parse("2026-01-02T09:30:00Z")
    end_at   = Time.parse("2026-01-02T16:00:00Z")
    result   = StocksService.get_minute_prices(ticker, start_at, end_at)

    assert_equal 0, result
    assert_equal 0, TickerMinutePrice.where(ticker: ticker).count
  end

  test "get_minute_prices upserts bars and returns true" do
    ticker   = tickers(:aapl)
    start_at = Time.parse("2026-01-02T09:30:00Z")
    end_at   = Time.parse("2026-01-02T16:00:00Z")

    @mock_client.define_singleton_method(:bars) do |*|
      [ { "t" => "2026-01-02T09:30:00Z", "o" => 150.0, "h" => 151.0, "l" => 149.5, "c" => 150.5, "v" => 10_000, "vw" => 150.2, "n" => 200 } ]
    end

    result = StocksService.get_minute_prices(ticker, start_at, end_at)

    assert result
    price = TickerMinutePrice.find_by(ticker: ticker, start_at: start_at)
    assert price
    assert_equal 150.0, price.price_open
    assert_equal 150.2, price.vwap
  end

  test "get_minute_prices is idempotent on repeated calls" do
    ticker   = tickers(:aapl)
    start_at = Time.parse("2026-01-02T09:30:00Z")
    end_at   = Time.parse("2026-01-02T16:00:00Z")
    bar      = { "t" => "2026-01-02T09:30:00Z", "o" => 150.0, "h" => 151.0, "l" => 149.5, "c" => 150.5, "v" => 10_000, "vw" => 150.2, "n" => 200 }
    @mock_client.define_singleton_method(:bars) { |*| [ bar ] }

    StocksService.get_minute_prices(ticker, start_at, end_at)
    StocksService.get_minute_prices(ticker, start_at, end_at)

    assert_equal 1, TickerMinutePrice.where(ticker: ticker).count
  end

  # --- get_news ---

  test "get_news creates news records and tags them to the ticker" do
    @mock_client.define_singleton_method(:asset) { |*| { "name" => "Apple Inc.", "exchange" => "NASDAQ" } }
    @mock_client.define_singleton_method(:news) do |*|
      [
        {
          "headline"   => "Apple Launches New Product",
          "author"     => "John Doe",
          "source"     => "Reuters",
          "summary"    => "Apple announced...",
          "url"        => "https://reuters.com/apple-launch",
          "created_at" => "2026-03-01T10:00:00Z",
          "images"     => [
            { "size" => "thumb", "url" => "https://img.example.com/thumb.jpg" },
            { "size" => "large", "url" => "https://img.example.com/large.jpg" }
          ]
        }
      ]
    end

    assert_difference "News.count", 1 do
      result = StocksService.get_news("AAPL", 90.days.ago)
      assert result
    end

    news = News.find_by(article_url: "https://reuters.com/apple-launch")
    assert_equal "Apple Launches New Product", news.headline

    ticker = Ticker.find_by(symbol: "AAPL")
    assert_includes ticker.news_sources, news
  end

  test "get_news is idempotent and does not duplicate news on repeated calls" do
    @mock_client.define_singleton_method(:asset) { |*| { "name" => "Apple Inc.", "exchange" => "NASDAQ" } }
    article = {
      "headline" => "Apple Launches New Product", "author" => "John Doe", "source" => "Reuters",
      "summary" => "Apple announced...", "url" => "https://reuters.com/apple-launch-2",
      "created_at" => "2026-03-01T10:00:00Z", "images" => []
    }
    @mock_client.define_singleton_method(:news) { |*| [ article ] }

    StocksService.get_news("AAPL", 90.days.ago)

    assert_no_difference "News.count" do
      StocksService.get_news("AAPL", 90.days.ago)
    end
  end

  test "get_news handles articles with no images gracefully" do
    @mock_client.define_singleton_method(:asset) { |*| { "name" => "Apple Inc.", "exchange" => "NASDAQ" } }
    @mock_client.define_singleton_method(:news) do |*|
      [ { "headline" => "No Image Article", "author" => "Jane", "source" => "Bloomberg",
          "summary" => "...", "url" => "https://bloomberg.com/no-image",
          "created_at" => "2026-03-02T08:00:00Z", "images" => [] } ]
    end

    StocksService.get_news("AAPL", 90.days.ago)

    news = News.find_by(article_url: "https://bloomberg.com/no-image")
    assert news
  end

  private

  def build_mock_client
    client = Object.new
    client.define_singleton_method(:asset) { |*| {} }
    client.define_singleton_method(:bars)  { |*| [] }
    client.define_singleton_method(:news)  { |*| [] }
    client
  end
end
