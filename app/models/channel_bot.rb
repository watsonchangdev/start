class ChannelBot < ApplicationRecord
  enum :bot_type, Enums::Channels::BotType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :channel
  has_many :messages, class_name: "ChannelMessage", as: :sent_by

  validates :bot_type, inclusion: { in: Enums::Channels::BotType.values.map(&:serialize) }

  private
end
