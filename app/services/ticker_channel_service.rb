class TickerChannelService
  def create_new_channel(ticker_symbol, participant_users: [])
    ticker = StocksService.create_or_get_by_ticker(ticker_symbol)

    channel = Channel.create!(
      name:         ticker.symbol,
      channel_type: Channel::ChannelType::Ticker.serialize,
      description:  "#{ticker.name} (#{ticker.symbol})"
    )

    participant_users.each do |user|
      channel.user_participants.create!(user: user)
    end

    channel.bot_participants.create!(bot_type: "market_data", username: "MarketBot")

    channel
  end
end
