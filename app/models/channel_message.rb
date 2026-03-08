class ChannelMessage < ApplicationRecord
  enum :message_type, Enums::Channels::MessageType.values.to_h { |v| [ v.serialize.to_sym, v.serialize ] }

  belongs_to :channel
  belongs_to :sent_by, polymorphic: true, optional: true

  private
end
