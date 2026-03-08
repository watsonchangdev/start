module Enums
  module Channels
    class ChannelType < T::Enum
      enums do
        Ticker  = new("ticker")
        Chat    = new("chat")
        Feature = new("feature")
      end
    end

    class BotType < T::Enum
      enums do
        News          = new("news")
        Analytics     = new("analytics")
        Notifications = new("notifications")
      end
    end

    class MessageType < T::Enum
      enums do
        UserMessage  = new("user_message")
        DataTable    = new("data_table")
        Notification = new("notification")
        MediaLink    = new("media_link")
      end
    end
  end
end
