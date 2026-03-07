class SyncMinutePricesJob < ApplicationJob
  queue_as :default

  def perform
    end_at   = Time.current.beginning_of_minute
    start_at = end_at - 15.minutes

    Ticker.find_each do |ticker|
      StocksService.get_minute_prices(ticker, start_at, end_at)
    end
  end
end
