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

  def option_positions
    channel = Channel.find_by!(uuid: params[:uuid])

    option_positions = current_user.option_positions
      .includes(:ticker, option_contract: [ :minute_prices, :daily_prices ])

    positions = PositionService.get_realtime_option_positions(option_positions)
    positions = positions.select { |p| p.status == Enums::Trades::PositionStatus::Open } if filter_open_only?

    position_data = JSON.parse(OptionPositionResource.new(positions).serialize)

    message = channel.messages.create!(
      sent_by:      channel.bot_participants.find_by!(bot_type: Enums::Channels::BotType::Analytics.serialize),
      content:      "Option Positions",
      message_type: Enums::Channels::MessageType::DataTable.serialize,
      metadata:     { data: position_data }
    )

    render json: ChannelMessageResource.new(message).serialize, status: :created
  rescue ActiveRecord::RecordNotFound
    render_error "Channel not found", status: :not_found
  end

  private

  def filter_open_only?
    params[:status].blank? || params[:status] == "open"
  end

  def channel_params
    params.expect(channel: [ :name, :channel_type, :description ])
  end
end
