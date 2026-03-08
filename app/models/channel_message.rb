class ChannelMessage < ApplicationRecord
  class MessageType < T::Enum
    enums do
      UserMessage  = new("user_message")
      DataTable    = new("data_table")
      Notification = new("notification")
    end
  end

  enum :message_type, MessageType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :channel
  belongs_to :sent_by, polymorphic: true

  private
end
