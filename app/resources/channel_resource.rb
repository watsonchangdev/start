class ChannelResource
  include Alba::Resource

  attributes :id, :uuid, :name, :description

  attribute :created_at do |channel|
    channel.created_at.iso8601
  end
end