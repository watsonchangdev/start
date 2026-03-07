class SyncNewsJob < ApplicationJob
  queue_as :default

  def perform
    symbols = Ticker.pluck(:symbol)

    symbols.each do |symbol|
      StocksService.get_news(symbol, 24.hours.ago)
    end
  end
end
