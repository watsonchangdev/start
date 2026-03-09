class ChannelService
  class << self
    def create_ticker_channel(ticker_symbol, participant_users: [])
      ticker = StocksService.create_or_get_by_ticker(ticker_symbol)

      channel = Channel.create!(
        name:         ticker.symbol,
        channel_type: Enums::Channels::ChannelType::Ticker.serialize,
        description:  "#{ticker.name} (#{ticker.symbol})"
      )

      participant_users.each do |user|
        channel.user_participants.create!(user: user)
      end

      channel.bot_participants.create!(bot_type: Enums::Channels::BotType::News.serialize, username: "NewsBot")
      channel.bot_participants.create!(bot_type: Enums::Channels::BotType::Notifications.serialize, username: "NotificationsBot")

      channel
    end

    def create_feature_channel(channel_name, participant_users: [])
      channel = Channel.create!(
        name:         channel_name,
        channel_type: Enums::Channels::ChannelType::Feature.serialize
      )

      participant_users.each do |user|
        channel.user_participants.create!(user: user)
      end

      channel
    end
  end
end
