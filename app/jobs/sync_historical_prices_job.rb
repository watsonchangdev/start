class SyncHistoricalPricesJob < ApplicationJob
  queue_as :default

  HISTORICAL_DATE_RANGE = 6.months

  def perform
    start_date = HISTORICAL_DATE_RANGE.ago.to_date
    end_date   = Date.today

    Ticker.find_each do |ticker|
      StocksService.get_daily_prices(ticker, start_date, end_date)
    end

    OptionContract.where(expires_on: Date.today..).find_each do |contract|
      OptionsService.get_daily_prices(contract.symbol, start_date, end_date)
    end
  end
end
