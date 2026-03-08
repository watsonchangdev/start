class ChannelBot < ApplicationRecord
  belongs_to :channel
  has_many :messages, class_name: "ChannelMessage", as: :sent_by

  private
end
