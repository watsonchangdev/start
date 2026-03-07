class Api::V1::ChannelsController < Api::V1::BaseController
  skip_before_action :require_api_authentication, only: [:index]

  def index
    channels = Channel.order(:name)
    render json: ChannelResource.new(channels).serialize
  end

  def create
    channel = Channel.new(channel_params)
    if channel.save
      render json: ChannelResource.new(channel).serialize, status: :created
    else
      render json: { errors: channel.errors.transform_values(&:first) }, status: :unprocessable_entity
    end
  end

  private

  def channel_params
    params.expect(channel: [:name, :description])
  end
end
