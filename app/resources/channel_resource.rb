class ChannelResource
  include Alba::Resource

  attributes :uuid, :name, :description

  attribute :created_at do |channel|
    channel.created_at.iso8601
  end
end