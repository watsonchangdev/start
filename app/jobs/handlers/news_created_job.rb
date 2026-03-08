module Handlers
  class NewsCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler
    queue_as :default

    def perform(event)
      ticker_uuid = event.data[:ticker][:uuid]
      ticker = Ticker.find_by!(uuid: ticker_uuid)

      news = News.find_by!(uuid: event.data[:uuid])

      Channel.where(channel_type: Channel::ChannelType::Ticker.serialize, name: ticker.symbol).find_each do |channel|
        news_bot = channel.bot_participants.find_by!(bot_type: ChannelBot::BotType::News.serialize)

        channel.messages.create!(
          sent_by:      news_bot,
          message_type: ChannelMessage::MessageType::Notification.serialize,
          content:      news.headline,
          metadata:     { news_uuid: news.uuid }
        )
      end
    end
  end
end
