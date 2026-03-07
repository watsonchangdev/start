class Api::V1::ChannelsController < Api::V1::BaseController
  skip_before_action :require_api_authentication, only: [:index]

  def index
    channels = Channel.order(:name)

    render json: ChannelResource.new(channels).serialize
  end
end
