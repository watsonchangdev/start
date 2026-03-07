class ChannelMessageResource
  include Alba::Resource

  attributes :uuid, :content, :message_type

  attribute :username do |message|
    sender = message.sent_by
    sender.is_a?(User) ? sender.email_address : sender.username
  end

  attribute :created_at do |message|
    message.created_at.iso8601
  end
end
