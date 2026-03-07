class SyncHistoricalPricesJob < ApplicationJob
  queue_as :default

  def perform
    start_date = 2.years.ago.to_date
    end_date   = Date.today

    Ticker.find_each do |ticker|
      StocksService.get_daily_prices(ticker, start_date, end_date)
    end
  end
end
