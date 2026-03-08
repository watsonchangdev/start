module Handlers
  class NewsCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler
    queue_as :default

    def perform(event)
      ticker_uuid = event.data[:ticker][:uuid]
      ticker = Ticker.find_by!(uuid: ticker_uuid)

      news = News.find_by!(uuid: event.data[:uuid])

      Channel.where(channel_type: Enums::Channels::ChannelType::Ticker.serialize, name: ticker.symbol).find_each do |channel|
        news_bot = channel.bot_participants.find_by!(bot_type: Enums::Channels::BotType::News.serialize)

        channel.messages.create!(
          sent_by:      news_bot,
          message_type: Enums::Channels::MessageType::MediaLink.serialize,
          content:      news.headline,
          metadata:     {
            news_uuid:     news.uuid,
            source_url:    news.article_url,
            thumbnail_url: news.thumb_url,
            ticker_price:  ticker.get_price_as_of(news.published_at)
          }
        )
      end
    end
  end
end
