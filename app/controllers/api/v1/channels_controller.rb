class Api::V1::ChannelsController < Api::V1::BaseController
  skip_before_action :require_api_authentication, only: [ :index ]

  def index
    channels = Channel.order(:name)
    render json: ChannelResource.new(channels).serialize
  end

  def create
    user_ids = params[:channel][:participant_user_ids].presence || [ current_user.id ]
    users = User.where(id: user_ids)

    case channel_params[:channel_type]
    when Enums::Channels::ChannelType::Ticker.serialize
      channel = ChannelService.create_ticker_channel(channel_params[:name], participant_users: users)
    when Enums::Channels::ChannelType::Feature.serialize
      channel = ChannelService.create_feature_channel(channel_params[:name], participant_users: users)
    end

    render json: ChannelResource.new(channel).serialize, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.transform_values(&:first) }, status: :unprocessable_entity
  end

  private

  def channel_params
    params.expect(channel: [ :name, :channel_type, :description ])
  end
end
