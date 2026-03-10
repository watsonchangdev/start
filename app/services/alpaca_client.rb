class AlpacaClient
  DATA_URL    = "https://data.alpaca.markets"
  TRADING_URL = "https://paper-api.alpaca.markets"

  Error = Class.new(StandardError)
  RateLimitError = Class.new(Error)

  def initialize
    @api_key    = ENV.fetch("ALPACA_API_KEY")
    @api_secret = ENV.fetch("ALPACA_API_SECRET")
  end

  # Returns an array of news articles for the given symbol.
  # Automatically follows pagination via next_page_token.
  # params: start:, end:, limit:, sort:, include_content:
  def news(symbol, **params)
    results = []
    page_token = nil
    params = { start: 90.days.ago.iso8601, **params }

    loop do
      body = data_get("/v1beta1/news", symbols: symbol, **params, limit: params.fetch(:limit, 50), page_token:)
      results.concat(body.fetch("news", []))

      page_token = body["next_page_token"]
      break if page_token.nil?
    end

    results
  end

  # Returns basic asset info for a symbol: name, exchange, class, tradable, etc.
  # https://docs.alpaca.markets/reference/getasset
  def asset(symbol)
    trading_get("/v2/assets/#{URI.encode_uri_component(symbol)}")
  end

  # Returns a single option contract by its OCC symbol (e.g. "AAPL250620C00190000").
  # https://docs.alpaca.markets/reference/getoption
  def option_contract(occ_symbol)
    trading_get("/v2/options/contracts/#{URI.encode_uri_component(occ_symbol)}")
  end

  # Returns OHLCV bars for an option contract.
  # Automatically follows pagination via next_page_token.
  # params: timeframe:, start:, end:, limit:
  # https://docs.alpaca.markets/reference/optionbars
  def option_bars(occ_symbol, **params)
    results = []
    page_token = nil

    loop do
      body = data_get("/v1beta1/options/bars", symbols: occ_symbol, **params, limit: params.fetch(:limit, 1000), page_token:)
      results.concat(body.dig("bars", occ_symbol) || [])

      page_token = body["next_page_token"]
      break if page_token.nil?
    end

    results
  end

  # Returns an array of bar hashes for the given symbol.
  # Automatically follows pagination via next_page_token.
  # params: timeframe:, start:, end:, limit:, feed:, adjustment:
  def stock_bars(symbol, **params)
    results = []
    page_token = nil

    loop do
      body = data_get("/v2/stocks/#{URI.encode_uri_component(symbol)}/bars", **params, limit: params.fetch(:limit, 1000), page_token:)
      results.concat(body.fetch("bars", nil) || [])

      page_token = body["next_page_token"]
      break if page_token.nil?
    end

    results
  end

  private

  def data_connection
    @data_connection ||= build_connection(DATA_URL)
  end

  def trading_connection
    @trading_connection ||= build_connection(TRADING_URL)
  end

  def build_connection(base_url)
    Faraday.new(base_url) do |f|
      f.headers["APCA-API-KEY-ID"]     = @api_key
      f.headers["APCA-API-SECRET-KEY"] = @api_secret
      f.headers["Accept"]              = "application/json"
      f.response :raise_error
    end
  end

  def data_get(path, **params)
    response = data_connection.get(path, params.compact)
    JSON.parse(response.body)
  rescue Faraday::TooManyRequestsError
    raise RateLimitError, "Alpaca rate limit exceeded"
  rescue Faraday::Error => e
    raise Error, "Alpaca API error: #{e.message}"
  end

  def trading_get(path, **params)
    response = trading_connection.get(path, params.compact)
    JSON.parse(response.body)
  rescue Faraday::TooManyRequestsError
    raise RateLimitError, "Alpaca rate limit exceeded"
  rescue Faraday::Error => e
    raise Error, "Alpaca API error: #{e.message}"
  end
end
