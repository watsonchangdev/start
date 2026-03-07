class Api::V1::ChannelMessagesController < Api::V1::BaseController
  skip_before_action :require_api_authentication, only: [:index]

  before_action :set_channel

  def index
    messages = @channel.messages.includes(:sent_by).order(:created_at)
    render json: ChannelMessageResource.new(messages).serialize
  end

  def create
    message = @channel.messages.build(message_params)
    message.sent_by = current_user
    message.message_type = ChannelMessage::MessageType::UserMessage.serialize

    if message.save
      render json: ChannelMessageResource.new(message).serialize, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_channel
    @channel = Channel.find_by!(uuid: params[:channel_uuid])
  rescue ActiveRecord::RecordNotFound
    render_error "Channel not found", status: :not_found
  end

  def message_params
    params.expect(channel_message: [ :content ])
  end
end
