class SyncMinutePricesJob < ApplicationJob
  queue_as :default

  REALTIME_TIME_RANGE = 15.minutes

  def perform
    end_at   = Time.current.beginning_of_minute
    start_at = end_at - REALTIME_TIME_RANGE

    Ticker.find_each do |ticker|
      StocksService.get_minute_prices(ticker, start_at, end_at)
    end
  end
end
