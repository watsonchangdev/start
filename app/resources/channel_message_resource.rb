class ChannelMessageResource
  include Alba::Resource

  attributes :uuid, :content, :message_type, :metadata

  attribute :username do |message|
    sender = message.sent_by
    sender.username || "Anonymous"
  end

  attribute :created_at do |message|
    message.created_at.iso8601
  end
end
