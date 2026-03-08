module Handlers
  class NewsCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler
    queue_as :default

    def perform(event)
      ticker_uuid = event.data[:ticker][:uuid]
      ticker = Ticker.find_by!(uuid: ticker_uuid)
    end
  end
end
