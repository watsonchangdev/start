class ChannelBot < ApplicationRecord
  class BotType < T::Enum
    enums do
      News          = new("news")
      Analytics     = new("analytics")
      Notifications = new("notifications")
    end
  end

  enum :bot_type, BotType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :channel
  has_many :messages, class_name: "ChannelMessage", as: :sent_by

  validates :bot_type, inclusion: { in: BotType.values.map(&:serialize) }

  private
end
