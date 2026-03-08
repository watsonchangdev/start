class SyncHistoricalPricesJob < ApplicationJob
  queue_as :default

  HISTORICAL_DATE_RANGE = 2.years

  def perform
    start_date = HISTORICAL_DATE_RANGE.ago.to_date
    end_date   = Date.today

    Ticker.find_each do |ticker|
      StocksService.get_daily_prices(ticker, start_date, end_date)
    end
  end
end
