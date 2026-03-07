class Api::V1::ChannelsController < Api::V1::BaseController
  def index
    channels = Channel.order(:name)

    render json: ChannelResource.new(channels).serialize
  end
end
