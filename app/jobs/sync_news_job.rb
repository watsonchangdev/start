class SyncNewsJob < ApplicationJob
  queue_as :default

  def perform
    symbols = Ticker.pluck(:symbol)
    SyncService.sync_news(symbols)
  end
end
