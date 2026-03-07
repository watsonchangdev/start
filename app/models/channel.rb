class Channel < ApplicationRecord
  has_many :user_participants, class_name: "ChannelUser"
  has_many :bot_participants, class_name: "ChannelBot"
  has_many :messages, class_name: "ChannelMessage"

  private

end
