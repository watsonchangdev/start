class Channel < ApplicationRecord
  class ChannelType < T::Enum
    enums do
      Ticker   = new("ticker")
      Chat     = new("chat")
      Feature  = new("feature")
    end
  end

  enum :channel_type, ChannelType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  has_many :user_participants, class_name: "ChannelUser"
  has_many :bot_participants, class_name: "ChannelBot"
  has_many :messages, class_name: "ChannelMessage"

  normalizes :name, with: ->(n) { n.strip }

  before_validation :normalize_channel_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true

  private

  def normalize_channel_name
    self.name = name.upcase if channel_type == ChannelType::Ticker.serialize
  end
end
