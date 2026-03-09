class SyncNewsJob < ApplicationJob
  queue_as :default

  SYNC_JOB_TIME_RANGE = 2.hours

  def perform
    symbols = Ticker.pluck(:symbol)

    symbols.each do |symbol|
      StocksService.get_news(symbol, SYNC_JOB_TIME_RANGE.ago.beginning_of_hour)
    end
  end
end
