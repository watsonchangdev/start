class SyncHistoricalJob < ApplicationJob
  queue_as :default

  def perform
    SyncService.sync_historical
  end
end
