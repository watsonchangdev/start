class Api::V1::ChannelsController < Api::V1::BaseController
  skip_before_action :require_api_authentication, only: [ :index ]

  def index
    channels = Channel.order(:name)
    render json: ChannelResource.new(channels).serialize
  end

  def create
    if channel_params[:channel_type] == Channel::ChannelType::Ticker.serialize
      user_ids = params[:channel][:participant_user_ids].presence || [ current_user.id ]
      users = User.where(id: user_ids)
      channel = TickerChannelService.new.create_new_channel(channel_params[:name], participant_users: users)

      render json: ChannelResource.new(channel).serialize, status: :created
    else
      channel = Channel.new(channel_params)
      if channel.save
        render json: ChannelResource.new(channel).serialize, status: :created
      else
        render json: { errors: channel.errors.transform_values(&:first) }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.transform_values(&:first) }, status: :unprocessable_entity
  rescue AlpacaClient::Error => e
    render json: { errors: { ticker: e.message } }, status: :unprocessable_entity
  end

  private

  def channel_params
    params.expect(channel: [ :name, :channel_type, :description ])
  end
end
