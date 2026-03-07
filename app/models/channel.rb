class Channel < ApplicationRecord
  has_many :user_participants, class_name: "ChannelUser"
  has_many :bot_participants, class_name: "ChannelBot"
  has_many :messages, class_name: "ChannelMessage"

  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }, allow_blank: true

end
