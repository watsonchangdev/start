class ChannelMessageResource
  include Alba::Resource

  attributes :id, :uuid, :content, :message_type

  attribute :created_at do |message|
    message.created_at.iso8601
  end

  attribute :sent_by do |message|
    sender = message.sent_by
    {
      id: sender.id,
      type: message.sent_by_type,
      display_name: sender.is_a?(User) ? sender.email_address : sender.username
    }
  end
end
